# MusikApp 

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
1. Открывается экран → состояние `.initial`
2. Пользователь нажимает "Войти" → состояние `.loading`
3. Успешно → переход в `CatalogModule`
4. Ошибка → состояние `.error(...)`

### Протоколы
- `AuthView` — UI показывает состояние
- `AuthPresenter` — логика представления
- `AuthInteractor` — бизнес-логика
- `AuthRouter` — навигация


## CatalogModule  
Каталог музыки: рекомендации, популярные плейлисты, альбомы, артисты

###  Вход  
- `userId: String` — идентификатор пользователя (передаётся после авторизации)

### Выход  
- `didSelectPlaylist(_ playlistId: String)` — пользователь выбрал плейлист  
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
`CatalogView` - UI отображает состояние через `render(_:)`
`CatalogPresenter` - Обрабатывает события: выбор плейлиста, выход 
`CatalogInteractor` - Загружает данные через `CatalogService` 
`CatalogRouter` - Управляет навигацией: переход в детали или выход 

