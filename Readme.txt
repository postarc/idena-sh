В составе ветки находятся несколько скриптов:
install.sh - основной скрипт установки ноды
autoupdate.sh - вспомогательный скрипт создания задачи автообновления ноды
automine.sh - вспомогательный скрипт создания задачи автозапуска майнинга (временно не поддерживается, так как в нем нет потребности)
remove.sh - скрипт, полностью удаляющий ноду и все созданные задачи (Не забудьте сохранить nodekey!)

Скрипт создает в текущем каталоге каталоги idena, idena-scripts и открывает порты 40403 и 40404.
В каталоге idena находится блокчейн ноды и демон idena-node.
В каталоге idena-scripts находится скрипт автообновления ноды, который запускается посредством crontab один раз в час.
Сюда же загружаются и проверяются версии исходников с https://github.com/idena-network/idena-go.git
Скрипт автообновления сверяет версию исходников с версией бинарника idena-node, если они отличаются, то скачивает новый релиз.
Запуск ноды осуществляется через сервис systemd.
Изенить параметры запуска можно через редактирование файла /etc/systemd/system/idena.service
Порты по умолчанию:
IPFS port (default 40403)
Node tcp port (default 40404)
Нода запускается с параметром --profile=lowpower

Start idena node:     sudo systemctl start idena.service
Stop idena node:      sudo systemctl stop idena.service
Enabe idena service:  sudo systemctl enable idena.service
Disable idena service:  sudo systemctl disable idena.service
Status idena node:      sudo systemctl status idena.service

For idena.service file editing:   sudo nano /etc/systemd/system/idena.service
After editing idena.service file: sudo systemctl daemon-reload
The log is available on command:  tail -f ~/idena/datadir/logs/output.log

Просмотр/Редактирование API.KEY:
nano idena/datadir/api.key
Просмотр/Редактирование nodekey:
nano idena/datadir/keystore/nodekey

Для установки нескольких нод на один сервер, необходимо запустить скрипт разных пользователей. На момент установке пользователь должен входить в группу sudo,
после установки, для безопасности, пользователя можно удалить из группы суперпользователей. 
После отработки скрипта на экран будет выведен номер RPC-порта, этот номер нужно использовать при создании тунеля PUTTY.
Например, если порт равен 9009, то в настройках тунеля указать Source port: 9999 , Destination: localhost:9009
Далее, значение Source port необходимо будет прописать в настройки кошелька во вкладке NODE в поле Node address": http://localhost:9999
Чуть ниже, в поле Node api key требуется указать значение, содержащееся в файле idena/datadir/api.key, которое так же выводится на экран.
