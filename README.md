# MusikApp

## Clean swift 

- Работал с чистой архитектурой в обычной жизни -> решил попробовать и тут
- Думаю, будет интереснее, чем просто MV**
- Нравится подход с четким разделением слоев

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
    case loading
    case content(sections: [CatalogSection])
    case empty
    case error(message: String)
}
```

### Основные сценарии  
1. **Открытие экрана после входа**  
   - Получаем `userId`  
   - Состояние: `.loading`  
   - Загружаем данные через `CatalogService`  
2. **Данные загружены успешно**  
   - Состояние: `.content([CatalogSection])`  
   - Отображаем секции: "Рекомендации", "Популярные", "Новые"  
3. **Пользователь выбирает плейлист**  
   - Вызывается `presenter.didSelectPlaylist(playlistId)`  
   - Router открывает `PlaylistDetailModule`  
4. **Пользователь нажимает "Выйти"**  
   - Вызывается `presenter.didTapLogout()`  
   - Router возвращает в `AuthModule`

### Протоколы  
- `CatalogView` — UI отображает состояние через `render(_:)`  
- `CatalogPresenter` — Обрабатывает события: выбор плейлиста, выход  
- `CatalogInteractor` — Загружает данные через `CatalogService`  
- `CatalogRouter` — Управляет навигацией: переход в детали или выход  

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
