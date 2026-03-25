# MusikApp

## Clean swift 

- Работал с чистой архитектурой в обычной жизни -> решил попробовать и тут
- Думаю, будет интереснее, чем просто MV**
- Нравится подход с четким разделением слоев


## Запуск

- делаем run приложения
- правильные данные для входа захардкожены (login: user@example.com, password: password123)
- после успешного входа происходит переход на страницу со списком плейлистов (CatalogViewController)
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
Каталог музыки: рекомендации, популярные плейлисты, альбомы, артисты

### Вход  
- `userId: String` — идентификатор пользователя (передаётся после авторизации)

### Выход  
- `didSelectPlaylist(_ playlistId: String)` - пользователь выбрал плейлист  
- `didLogout()` — пользователь нажал "Выйти"

### Состояния UI  
```swift
enum CatalogViewState: Equatable {
    case idle
    case loading
    case content([PlaylistCellViewModel])
    case empty
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
3. **Пользователь выбирает плейлист**  
   - Вызывается `presenter.didSelectPlaylist(playlistId)`  
   - Router открывает `PlaylistDetailModule`  
4. **Пользователь нажимает "Выйти"**  
   - Вызывается `presenter.didTapLogout()`  
   - Router возвращает в `AuthModule`

### Протоколы  
- `CatalogView` — UI отображает состояние через `render(_:)`  
- `CatalogPresenter` — Обрабатывает события: выбор плейлиста, выход; маппит ошибки сети в текст для UI  
- `CatalogInteractor` — Загружает данные через `CatalogService`, маппит доменные модели в `PlaylistCellViewModel`; повторный вызов загрузки отменяет предыдущий `Task`  
- `CatalogRouter` — Управляет навигацией: переход в детали или выход  

### Лабораторная 4 — сеть и ViewModel списка

**API:** публичный [Discogs Database API](https://www.discogs.com/developers#page:database,search:database) — поиск по каталогу релизов. Для простых запросов **отдельный API-ключ не обязателен**, но нужен осмысленный **User-Agent** (у нас задаётся в `URLSessionNetworkClient`).

**Endpoint:** `GET https://api.discogs.com/database/search`  
Параметры в `RemoteCatalogService`: `q` (поисковая строка, по умолчанию `rock`), `type=release`, `per_page=30`.  
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

**Как проверить:** запустить приложение, войти (`user@example.com` / `password123`), открыть каталог. В консоли Xcode — лог из `CatalogViewController.render`.

**Сетевой клиент:** протокол `NetworkClient`, реализация `URLSessionNetworkClient` (async/await, `User-Agent`, таймаут, `JSONDecoder`).

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
