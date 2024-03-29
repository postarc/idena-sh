#### Предпочтительно запускать скрипт из домашнего каталога, для этого пред установкой перейти в него:
###### `cd ~`
#### Перед запуском скрипта требуется установить пакет git:
###### `sudo apt update`
###### `sudo apt install git`
*****************************************************
#### В составе ветки находятся несколько скриптов:
###### install.sh - основной скрипт установки ноды
###### autoupdate.sh - вспомогательный скрипт создания задачи автообновления ноды
###### automine.sh - вспомогательный скрипт создания задачи автозапуска майнинга (временно не поддерживается, так как в нем нет потребности)
###### remove.sh - скрипт, полностью удаляющий ноду и все созданные задачи (Не забудьте сохранить nodekey!)

#### Установка ноды производится 2-мя командами:
###### `git clone https://github.com/postarc/idena-sh.git`
###### `bash idena-sh/install.sh`

#### Удаление:
###### `git clone https://github.com/postarc/idena-sh.git`
###### `bash idena-sh/remove.sh`
******************************************************
#### Скрипт создает в текущем каталоге каталоги idena, idena-scripts и открывает порты.
#### В каталоге idena находится блокчейн ноды и демон idena-node.
#### В каталоге idena-scripts находится скрипт автообновления ноды, который запускается посредством crontab один раз в час.
#### Сюда же загружаются и проверяются версии [исходников](https://github.com/idena-network/idena-go.git)
#### Скрипт автообновления сверяет версию исходников с версией бинарника idena-node, если они отличаются, то скачивает новый релиз.
#### Запуск ноды осуществляется через сервис systemd.
#### Изенить параметры запуска можно через редактирование файла /etc/systemd/system/idena-$USER.service
### Порты по умолчанию:
###### IPFS port (default 40405)
###### Node tcp port (default 40404)
******************************************************
#### Нода запускается с параметром --profile=lowpower
#### Start idena node:     `sudo systemctl start idena.service`
#### Stop idena node:      `sudo systemctl stop idena.service`
#### Enabe idena service:  `sudo systemctl enable idena.service`
#### Disable idena service:  `sudo systemctl disable idena.service`
#### Status idena node:      `sudo systemctl status idena.service`

#### For idena.service file editing:   `sudo nano /etc/systemd/system/idena.service`
#### After editing idena.service file: `sudo systemctl daemon-reload`
#### The log is available on command:  `tail -f ~/idena/datadir/logs/output.log`

### Просмотр/Редактирование API.KEY:
###### `nano idena/datadir/api.key`
### Просмотр/Редактирование nodekey:
###### `nano idena/datadir/keystore/nodekey`
### После редактирования api.key/nodekey требуется перезапуск ноды:
###### `sudo systemctl restart idena-$USER.service`

###### После отработки скрипта на экран будет выведен номер RPC-порта, этот номер нужно использовать при создании тунеля PUTTY.
###### Если RPC-порт равер 9009, то в настройках тунеля указать Destination: localhost:9009, Source port - может быть любым из свободных номеров портов, например 9999.
###### Далее, значение Source port необходимо будет прописать в настройки кошелька во вкладке NODE в поле Node address, например: http://localhost:9999
###### Чуть ниже, в поле Node api key требуется указать значение, содержащееся в файле idena/datadir/api.key, которое так же выводится на экран.
# ![Idena's price](https://img.shields.io/badge/dynamic/json?color=inactive&label=Idena%3A&query=%24.idena.usd&suffix=%24&url=https%3A%2F%2Fapi.coingecko.com%2Fapi%2Fv3%2Fsimple%2Fprice%3Fids%3Didena%26vs_currencies%3Dusd)

