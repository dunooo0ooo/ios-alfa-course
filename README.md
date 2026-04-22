# MusikApp

## Clean swift 

- Работал с чистой архитектурой в обычной жизни -> решил попробовать и тут
- Думаю, будет интереснее, чем просто MV**
- Нравится подход с четким разделением слоев


## Запуск

- делаем run приложения
- правильные данные для входа захардкожены (login: user@example.com, password: password123)
- после успешного входа происходит переход на страницу со списком треков (`CatalogViewController`)
- если были предоставлены неправильные даннные, то получаем сообщение с ошибкой

## AuthModule  
Экран авторизации: ввод email и пароля, обработка нажатий, отображение состояний (загрузка, ошибка, успех), переход в `CatalogModule` после входа.

### Вход  
- Нет данных (первый экран)

### Выход  
- `didLoginSuccessfully(userId: String)`  
- `didFailWith(error: Error)`

### Состояния UI  
```swift
enum AuthViewState: Equatable {
    case initial
    case loading
    case content(email: String)
    case error(message: String)
}
```

### Сценарии  
1. Открывается экран -> состояние `.initial`  
2. Пользователь нажимает "Войти" -> состояние `.loading`  
3. Успешно → переход в `CatalogModule`  
4. Ошибка → состояние `.error(...)`

### Протоколы  
- `AuthView` - UI показывает состояние  
- `AuthPresenter` — логика представления  
- `AuthInteractor` — бизнес-логика  
- `AuthRouter` — навигация  

---

## CatalogModule  
Каталог музыки: список треков/релизов, полученных из API

### Вход  
- `userId: String` — идентификатор пользователя (передаётся после авторизации)

### Выход  
- `didSelectTrack(...)` - пользователь выбрал трек  
- `didLogout()` — пользователь нажал "Выйти"

### Состояния UI  
```swift
enum CatalogViewState: Equatable {
    case idle
    case loading
    case content([PlaylistCellViewModel])
    case empty(message: String)
    case error(message: String)
}
```

### Основные сценарии  
1. **Открытие экрана после входа**  
   - Получаем `userId`  
   - Состояние: `.loading`  
   - Асинхронно загружаем данные через `CatalogService` (`Task`, UI не блокируется)  
2. **Данные загружены успешно**  
   - Состояние: `.content([PlaylistCellViewModel])`  
   - В UI-слое только готовые ячейки (без DTO и парсинга)  
3. **Пользователь выбирает трек**  
   - Вызывается `interactor.didSelectTrack(id:title:subtitle:)`  
   - Router открывает `PlaylistDetailModule`  
4. **Пользователь нажимает "Выйти"**  
   - Вызывается `interactor.didTapLogout()`  
   - Router возвращает в `AuthModule`

### Протоколы  
- `CatalogView` — UI отображает состояние через `render(_:)` и управляет `UIRefreshControl` через `setRefreshing(_)`  
- `CatalogPresenter` — Состояния и маппинг `NetworkError` в текст; навигация через router  
- `CatalogInteractor` — Загрузка через `CatalogService`, кэш списка, локальный поиск без сети, `loadCatalog(..., isRefresh:)`  
- `CatalogRouter` — Управляет навигацией: переход в детали или выход  
- `CatalogListManager` — `UITableView` data source / delegate, reuse, делегирует выбор наружу  

### Лабораторная 4 — сеть и ViewModel списка

**API:** публичный [Discogs Database API](https://www.discogs.com/developers#page:database,search:database) — поиск по каталогу релизов. Для простых запросов **отдельный API-ключ не обязателен**, но нужен осмысленный **User-Agent** (у нас задаётся в `URLSessionNetworkClient`).

**Endpoint:** `GET https://api.discogs.com/database/search`  
Параметры в `RemoteCatalogService`: `q` (поисковая строка, по умолчанию `rock`), `type=release`, `per_page=100` (удобно для проверки скролла 100+).  
Ответ — JSON с полем **`results`**: массив найденных релизов (плюс блок `pagination`, для Codable декодируем только `results`).

**Пример в браузере (может потребоваться заголовок User-Agent):** см. [документацию Discogs](https://www.discogs.com/developers#page:database,search:database).

**Цепочка данных:** `DiscogsSearchResponseDTO` / `DiscogsSearchResultDTO` (Codable, для `cover_image` используется `CodingKeys`) → `CatalogListItem` → `PlaylistCellViewModel`.

**Поля `PlaylistCellViewModel` (что пойдёт в ячейку в лабе 5):**

| Поле | Источник из API |
|------|-----------------|
| `id` | `id` релиза (число в JSON → строка) |
| `title` | `title` |
| `subtitle` | `country` и `type` (например `US · release`) |
| `rightText` | `year` |
| `imageURL` | `cover_image`, иначе `thumb` |

**Ошибки:** тип `NetworkError` (сеть/таймаут, не-2xx, декодирование); во view уходит строка из `userMessage`.

**Офлайн / лимиты API:** при ошибке сети или декодирования подставляется `MusicApp/catalog_fallback.json` в формате Discogs (`results`).

**Как проверить (лаба 4):** запустить приложение, войти (`user@example.com` / `password123`), открыть каталог.

**Сетевой клиент:** протокол `NetworkClient`, реализация `URLSessionNetworkClient` (async/await, `User-Agent`, таймаут, `JSONDecoder`).

### Лабораторная 5 — список UIKit + компоненты

**Подход к списку:** `UITableView` + вынесенный **`CatalogListManager`** (`UITableViewDataSource` / `UITableViewDelegate`), переиспользуемая DS-ячейка **`DSListItemCell`**, которая конфигурируется через `DSListItemCellViewModel` из `PlaylistCellViewModel`. Таблица не пересобирается «с нуля» при каждом изменении: обновляется модель в менеджере и вызывается `reloadData()` (разумный компромисс без Diffable).

**Дополнительно из блока:**
- **D2** — **поиск:** `UISearchBar`, фильтрация по уже загруженным `CatalogListItem` без повторного запроса
- **D1** — **pull-to-refresh:** `UIRefreshControl`, повторная загрузка каталога с `isRefresh: true`

**Как открыть экран списка:** после успешного входа — push `CatalogViewController` (как и раньше).

**Состояния на экране:**
- **loading** — оверлей со спиннером при первой загрузке;
- **content** — таблица + поиск + pull-to-refresh;
- **empty** — текст из `empty(message:)` («Нет данных» с сервера или «Ничего не найдено» при фильтре поиска);
- **error** — сообщение и кнопка «Повторить» (`retryLoadCatalog`).

**Как увидеть error:** выключить сеть и зайти в каталог (или дождаться ошибки API); при наличии fallback из ЛР4 список может всё равно заполниться — тогда посмотреть сообщение об ошибке можно, временно отключив fallback в `RemoteCatalogService`.

**По tap на строку:** `CatalogRouter` открывает **`PlaylistDetailViewController`**

### Лабораторная 6 — дизайн-система

**Где лежит:** `MusicApp/DesignSystem`

**Токены:**
- `DS.Colors` — `background`, `surface`, `surfaceElevated`, `primary`, `textPrimary`, `textSecondary`, `error`, `separator`, `border`
- `DS.Typography` — `heroTitle`, `screenTitle`, `body`, `bodyStrong`, `subheadline`, `caption`, `button`
- `DS.Spacing` — `xSmall`, `small`, `medium`, `large`, `xLarge`, `xxLarge`, `screenInset`, `cornerRadius`, `fieldHeight`, `buttonHeight`
- дополнительно: `DSTextStyle` + `UILabel.apply(_:)` для централизованного применения текстовых стилей

**Компоненты:**
- `DSButton` — primary / secondary кнопка, поддерживает loading-state
- `DSTextField` — переиспользуемое поле ввода с title, placeholder и error-state
- `DSStateView` — единый компонент состояний `loading / empty / error` с action-кнопкой

**Где применено:**
- `AuthViewController` — поля ввода переведены на `DSTextField`, кнопка входа на `DSButton`, экран использует общие токены цветов/типографики/отступов
- `CatalogViewController` — поиск, фон, навигация и состояния экрана приведены к DS; `loading / empty / error` показываются через `DSStateView`
- `DSListItemCell` — общая DS-ячейка списка, использующая токены цветов, типографики и иконок

**Дополнительные задания по лабе 6:**
- `D3. TextStyle` — реализован `DSTextStyle` и расширение `UILabel.apply(_:)` в `MusicApp/DesignSystem/DS.swift`
- `D4. Компоненты форм` — реализован `DSTextField` с поддержкой `title`, `placeholder` и `error-state`
- `D5. DS для списка` — `DSListItemCell` сделана общей переиспользуемой ячейкой списка и оформлена через токены дизайн-системы

### Лабораторная 7 — Backend Driven UI

**Где лежит:**
- `MusicApp/DesignSystem/BackendDriven/BDUIModel.swift` — декодируемая recursive-модель BDUI
- `MusicApp/DesignSystem/BackendDriven/BDUIViewMapper.swift` — generic mapper под протоколом `BDUIViewMapping`
- `MusicApp/DesignSystem/BackendDriven/BDUIService.swift` — загрузка JSON-конфига с Echo API по стратегии `remote-first` и fallback на bundled/inline JSON
- `MusicApp/DesignSystem/BackendDriven/BDUIScreenViewController.swift` — экран, который получает JSON, маппит его в `UIView` и показывает без дополнительной ручной донастройки

**Что поддерживает модель:**
- `container`
- `stack`
- `label`
- `button`
- `image`
- `spacer`

**Что умеет JSON-модель:**
- рекурсивно описывать вложенные вью и сабвью
- декодироваться из JSON
- задавать axis / spacing / alignment / distribution для stack view
- задавать DS-токены цветов, типографики, отступов и скруглений
- задавать action для кнопок (`print`, `reload`, `navigateBack`)

**Как открыть:**
- войти в приложение
- на экране каталога нажать кнопку `BDUI` в левом верхнем углу

**Откуда грузится конфиг:**
- основной путь: `https://alfaitmo.ru/server/echo/ios-alfa-course%2Fbdui%2Fdemo`
- если сервер недоступен, возвращает `404` или JSON не декодируется, используется fallback
- bundled fallback: `MusicApp/bdui_demo_screen.json`
- если bundled JSON недоступен, используется inline fallback, собранный прямо в `EchoBDUIService`

**Как проверить через Echo API:**
- отправить свой JSON на путь `ios-alfa-course/bdui/demo`
- затем открыть экран `BDUI` в приложении
- экран попытается загрузиться с сервера первым, а при проблеме с сетью или отсутствующем конфиге откроется локальный fallback
- экран будет полностью собран через mapper из полученной JSON-модели без дополнительной ручной настройки после маппера
---

## PlaylistDetailModule  
Детали плейлиста: список треков, воспроизведение, добавление в избранное, возврат назад

### Вход  
- `playlistId: String` — идентификатор плейлиста (передаётся из `CatalogModule`)

### Выход  
- `didNavigateBack()` — пользователь нажал "Назад"  
- `didPlayTrack(at:)` — пользователь выбрал трек для воспроизведения  
- `didToggleFavorite(for:)` — пользователь поставил/снял лайк

### Состояния UI  
```swift
enum PlaylistDetailViewState: Equatable {
    case loading
    case content(tracks: [Track], isPlaying: Bool, currentIndex: Int?)
    case empty
    case error(message: String)
}
```

### Основные сценарии  
1. **Открытие экрана после выбора плейлиста**  
   - Получаем `playlistId`  
   - Состояние: `.loading`  
   - Загружаем треки через `PlaylistService`  
2. **Данные загружены успешно**  
   - Состояние: `.content([Track])`  
   - Отображаем список треков  
3. **Пользователь нажимает на трек**  
   - Вызывается `presenter.didTapTrack(at:)`  
   - Interactor запускает воспроизведение  
4. **Пользователь ставит/снимает лайк**  
   - Вызывается `presenter.didToggleFavorite(for:)`  
   - Interactor обновляет состояние  
5. **Пользователь нажимает "Назад"**  
   - Вызывается `presenter.didTapBack()`  
   - Router возвращает в `CatalogModule`

### Протоколы  
- `PlaylistDetailView` — UI отображает состояние через `render(_:)`  
- `PlaylistDetailPresenter` — Обрабатывает события: выбор трека, лайк, возврат  
- `PlaylistDetailInteractor` — Воспроизводит трек, обновляет избранное  
- `PlaylistDetailRouter` — Управляет навигацией: возврат назад  

---

## зависимости

```
+------------------+       +------------------+       +------------------+
| AuthViewController |     | AuthPresenter    |     | AuthInteractor   |
|                  |<----->|                  |<----->|                  |
|                  |       |                  |       |                  |
+------------------+       +------------------+       +------------------+
                                      ↓                      ↓
                              +------------------+   +------------------+
                              | AuthView         |   | AuthService      |
                              | (UI)             |   | (Domain)         |
                              +------------------+   +------------------+
                                      ↓
                              +------------------+
                              | AuthRouter       |
                              | (Navigation)     |
                              +------------------+
                                      ↓
                              +------------------+
                              | CatalogModule    |
                              +------------------+

+------------------+       +------------------+       +------------------+
| CatalogViewController | | CatalogPresenter | | CatalogInteractor |
|                    |<----->|                  |<----->|                  |
|                    |       |                  |       |                  |
+------------------+       +------------------+       +------------------+
                                      ↓                      ↓
                              +------------------+   +------------------+
                              | CatalogView      |   | CatalogService   |
                              | (UI)             |   | (Domain)         |
                              +------------------+   +------------------+
                                      ↓
                              +------------------+
                              | CatalogRouter    |
                              | (Navigation)     |
                              +------------------+
                                      ↓
                              +------------------+
                              | PlaylistDetailModule |
                              +------------------+

+------------------+       +------------------+       +------------------+
| PlaylistDetailViewController | | PlaylistDetailPresenter | | PlaylistDetailInteractor |
|                          |<----->|                          |<----->|                          |
|                          |       |                          |       |                          |
+------------------+       +------------------+       +------------------+
                                      ↓                      ↓
                              +------------------+   +------------------+
                              | PlaylistDetailView | | PlaylistService  |
                              | (UI)               | | (Domain)         |
                              +------------------+   +------------------+
                                      ↓
                              +------------------+
                              | PlaylistDetailRouter |
                              | (Navigation)         |
                              +------------------+
                                      ↓
                              +------------------+
                              | CatalogModule    |
                              +------------------+
```
