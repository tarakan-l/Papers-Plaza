# === Этап 1: Сборка приложения ===
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Копируем файл проекта и восстанавливаем NuGet-пакеты
COPY QueueApp.csproj ./
RUN dotnet restore

# Копируем весь исходный код и собираем проект в режиме Release
COPY . ./
RUN dotnet publish QueueApp.csproj -c Release -o /app/publish /p:UseAppHost=false

# === Этап 2: Финальный легковесный образ для запуска ===
FROM mcr.microsoft.com/dotnet/runtime:8.0
WORKDIR /app

# Забираем только скомпилированные файлы из этапа сборки
COPY --from=build /app/publish .

# Точка входа для запуска нашего консольного приложения
ENTRYPOINT ["dotnet", "QueueApp.dll"]
