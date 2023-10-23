#!/bin/bash

# Функция для архивирования и шифрования
create_archive() {
    read -p "Введите путь к файлу или папке: " source_path
    read -p "Введите путь для создания архива (пусто для использования текущей папки): " target_path
    read -p "Введите имя архива: " archive_name
    read -s -p "Введите пароль: " password
    echo

    if [ -z "$target_path" ]; then
        target_path="./"
    fi

    # Создаем временную папку
    temp_dir="$(mktemp -d "${target_path}/${archive_name}_temp.XXXXXX")"

    # Архивируем файл/папку
    # tar -czf "${temp_dir}/${archive_name}.tar.gz" "$source_path"
    tar -czf "${temp_dir}/${archive_name}.tar.gz" -C "$(dirname "$source_path")" "$(basename "$source_path")"

    # Шифруем архив с использованием пароля
    echo "$password" | gpg --batch --passphrase-fd 0 --output "${target_path}/${archive_name}" --symmetric --cipher-algo AES256 "${temp_dir}/${archive_name}.tar.gz"

    # Удаляем временную папку
    rm -r "$temp_dir"

    echo "Архив успешно создан и зашифрован."
}

# Функция для расшифровки
decrypt_archive() {
    read -p "Введите путь к зашифрованному архиву: " encrypted_archive
    read -p "Введите путь для распоковки архива (пусто для использования текущей папки): " target_path
    read -s -p "Введите пароль: " password
    echo

    if [ -z "$target_path" ]; then
        target_path="./"
    fi

    # Проверяем если в encrypted_archive не указан обсалютный путь то добавляем текущий
    if [[ "$encrypted_archive" != /* ]]; then
        encrypted_archive="$(pwd)/$encrypted_archive"
    fi

    # Получаем имя архива
    encrypted_archive_name="$(basename "$encrypted_archive")"

    # Создаем папку для расшифрованного архива
    decrypted_dir="$(mktemp -d "${target_path}/${encrypted_archive_name}_XXXXXX")"

    # Расшифровываем архив
    echo "$password" | gpg --batch --passphrase-fd 0 --output "${decrypted_dir}/decrypted.tar.gz" --decrypt "$encrypted_archive"

    # Распаковываем архив
    tar -xzf "${decrypted_dir}/decrypted.tar.gz" -C "$decrypted_dir"

    #Удаление временных файлов
    rm "${decrypted_dir}/decrypted.tar.gz"

    echo "Архив успешно расшифрован и извлечен в $decrypted_dir."
}

# Главное меню
while true; do
    echo "Выберите действие:"
    echo "1. Создать зашифрованный архив"
    echo "2. Расшифровать архив"
    echo "3. Выйти"
    read -p "Ваш выбор: " choice

    case $choice in
        1)
            create_archive
            ;;
        2)
            decrypt_archive
            ;;
        3)
            exit 0
            ;;
        *)
            echo "Неверный выбор. Попробуйте снова."
            ;;
    esac
done
