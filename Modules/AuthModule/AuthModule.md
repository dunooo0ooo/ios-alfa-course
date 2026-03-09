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
