# Notes

1. Доступ с виртуальной машины к Spanner

    Управлять доступом нужно при помощи Service Accounts. Заданным по умолчанию
    пользоваться плохо, всякие проблемы всплывают. Настроить грануллированный доступ
    с ним так и не удалось. Лучше просто создать нормальный Service Account и присвоить
    ему нужные роли.

    Изменение ролей у Service Account занимает некоторое время, т.о. изменение доступов
    происходит не мгновенно.

2. Spanner не умеет автоинкремент целочисленных ключей. Показалось странным, интересно
   будет почитать, почему так решили сделать.
