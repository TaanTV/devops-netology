Домашнее задание к занятию "10.05. Страж"

### Задание 1

Так как автономная система Sentry довольно требовательная к ресурсам система, мы будем использовать бесплатный облачный аккаунт.

Бесплатная облачная учетная запись имеет следующие ограничения:

* 5000 ошибок
* 10 000 транзакций
* Вложения 1 ГБ
Для подключения бесплатной облачной учетной записи:

зайдите на sentry.io

наж версии "Попробовать бесплатно"

викоризируйте авторизацию через ваш github-аккаунт

далее следуйте инструкциям

Для выполнения задания - пришлите скриншот меню Projects.

![https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/CI%2C%20%D0%BC%D0%BE%D0%BD%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D0%BD%D0%B3%20%D0%B8%20%D1%83%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5%20%D0%BA%D0%BE%D0%BD%D1%84%D0%B8%D0%B3%D1%83%D1%80%D0%B0%D1%86%D0%B8%D1%8F%D0%BC%D0%B8/Homework%20for%20the%20lesson%2010.05.%20Sentry/Project%20Sentry.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/CI%2C%20%D0%BC%D0%BE%D0%BD%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D0%BD%D0%B3%20%D0%B8%20%D1%83%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5%20%D0%BA%D0%BE%D0%BD%D1%84%D0%B8%D0%B3%D1%83%D1%80%D0%B0%D1%86%D0%B8%D1%8F%D0%BC%D0%B8/Homework%20for%20the%20lesson%2010.05.%20Sentry/Project%20Sentry.jpg)

### Задание 2

Создайте python проект и нажмите Generate sample eventдля генерации тестового события.

Изучите информацию, представленную в событии.

Перейдите в список событий проекта, выберите созданное вами и нажмите Resolved.

Для выполнения задания предоставьте скриншот Stack trace из этого события и список событий проекта, после Resolved.

![https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/CI%2C%20%D0%BC%D0%BE%D0%BD%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D0%BD%D0%B3%20%D0%B8%20%D1%83%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5%20%D0%BA%D0%BE%D0%BD%D1%84%D0%B8%D0%B3%D1%83%D1%80%D0%B0%D1%86%D0%B8%D1%8F%D0%BC%D0%B8/Homework%20for%20the%20lesson%2010.05.%20Sentry/resolved%20sentry.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/CI%2C%20%D0%BC%D0%BE%D0%BD%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D0%BD%D0%B3%20%D0%B8%20%D1%83%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5%20%D0%BA%D0%BE%D0%BD%D1%84%D0%B8%D0%B3%D1%83%D1%80%D0%B0%D1%86%D0%B8%D1%8F%D0%BC%D0%B8/Homework%20for%20the%20lesson%2010.05.%20Sentry/resolved%20sentry.jpg)

### Задание 3

Перейдите в создание правил алёртинга.

Выберите проект и создайте дефолтное правило алёртинга, без настройки полей.

Снова сгенерируйте событие Generate sample event.

Если всё было выполнено правильно - через некоторое время, вам на почту, привязанную к github аккаунту придёт оповещение о произошедшем событии.

Если сообщение не пришло - проверьте настройки аккаунта Sentry (например привязанную почту), что у вас не было sample issueдо того как вы его сгенерировали и то, что правило алёртинга выставлено по дефолту (во всех полях все). Также проверьте проект в котором вы создаете событие, возможно алёрт привязан к другому.

Для выполнения задания - пришлите скриншот тела сообщения из оповещения на почте.

Дополнительно поэкспериментируйте предписания алёртинга. Выбирайте разные условия отправки и создавайте примеры событий.

![https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/CI%2C%20%D0%BC%D0%BE%D0%BD%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D0%BD%D0%B3%20%D0%B8%20%D1%83%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5%20%D0%BA%D0%BE%D0%BD%D1%84%D0%B8%D0%B3%D1%83%D1%80%D0%B0%D1%86%D0%B8%D1%8F%D0%BC%D0%B8/Homework%20for%20the%20lesson%2010.05.%20Sentry/sentry%20alert.jpg](https://raw.githubusercontent.com/TaanTV/devops-netology/main/Netology%20dz/CI%2C%20%D0%BC%D0%BE%D0%BD%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D0%BD%D0%B3%20%D0%B8%20%D1%83%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5%20%D0%BA%D0%BE%D0%BD%D1%84%D0%B8%D0%B3%D1%83%D1%80%D0%B0%D1%86%D0%B8%D1%8F%D0%BC%D0%B8/Homework%20for%20the%20lesson%2010.05.%20Sentry/sentry%20alert.jpg)