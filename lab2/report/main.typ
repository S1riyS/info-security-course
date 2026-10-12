#set document(title: "ЛР2 Разрешения NTFS")
#set page(paper: "a4", margin: (top: 2cm, bottom: 2cm, left: 2cm, right: 2cm))

#set text(lang: "ru", font: ("Liberation Serif", "Times New Roman"), size: 14pt)
#set par(justify: true, leading: 0.8em, first-line-indent: 1.25cm)
#set heading(numbering: "1.")
#show heading: set par(first-line-indent: 0pt)

#show raw: set text(font: ("Liberation Mono", "Consolas"), size: 11pt)
#let source(path, lang) = block(
  fill: luma(240),
  stroke: 0.5pt + luma(180),
  inset: 10pt,
  radius: 4pt,
  below: 1.5em,
  raw(read(path), lang: lang, block: true),
)

// Титульный лист

#align(center)[
  #set par(first-line-indent: 0pt)
  #text(size: 12pt)[
    Федеральное государственное автономное образовательное учреждение\
    высшего образования\
    *«Национальный исследовательский университет ИТМО»*
  ]

  #v(0.4cm)
  #text(size: 12pt)[Факультет программной инженерии и компьютерной техники]

  #v(3.5cm)

  #text(size: 16pt, weight: "bold")[
    Лабораторная работа №2\
    «Разрешения NTFS»
  ]

  #v(0.6cm)
  #text(size: 13pt)[по дисциплине «Информационная безопасность»]

  #v(5cm)

  #align(right)[
    #set par(first-line-indent: 0pt)
    #grid(
      columns: 10cm,
      row-gutter: 0.5em,
      align: (right, left),
      [*Студент:*],
      [Анкудинов Кирилл Константинович],
      [Кортыш Константин Олегович],
      [Соколов Артём Олегович],
      [*Группа:*],
      [P3418],
      [*Преподаватель:*],
      [Оголюк Александр Александрович],
    )
  ]

  #v(1fr)
  #text(size: 12pt)[Санкт-Петербург, 2026]
]

#pagebreak()

#set page(numbering: "1")
#counter(page).update(1)

#outline(title: "Содержание")

#pagebreak()

= Ход работы

- Подготовка и правила 1--2 выполнены в Windows 10.0.19045.6456, правила 3--5 -- в Windows 11 Pro 25H2 (26200.9457)
- Проверки доступа выполняются от локального пользователя `stud` в отдельном окне `cmd`

== Подготовка

Пользователь `stud` создан. Учётная запись активна и входит в группу «Пользователи».

```bash
net user stud * /add
net user stud
```

#figure(
  image("images/1_stud_account.png", width: 70%),
  caption: [Создание учётной записи stud],
)

#pagebreak()

Учётная запись «Администратор» включена, пароль задан.

```bash
Enable-LocalUser -Name 'Администратор'
Set-LocalUser -Name 'Администратор' -Password (Read-Host -AsSecureString)
```

#figure(
  image("images/2_administrator.png", width: 100%),
  caption: [Включение учётной записи Администратор],
)

Окно `cmd` запущено от имени `stud`. `whoami` показал `desktop-bcv3lvn\stud`, среди групп — «Все» и «Пользователи».

```bash
runas /user:stud "cmd /k"
whoami
whoami /groups
```

#figure(
  image("images/3_runas_whoami.png", width: 80%),
  caption: [Окно cmd от имени stud],
)

== Иерархия каталогов

Дерево создано на томе `D:` (NTFS). В нём есть файлы `.txt`, `.log` и `.exe`. Папка `owned` изначально оставлена пустой.

#source("scripts/tree.bat", "bash")

#figure(
  image("images/4_tree.png", width: 60%),
  caption: [Иерархия каталогов и файлов -- `tree D:\lab2 /F`],
)

== Правило 1. Разрешения файла и папки

На папку `NOACCESS` для `stud` поставлен запрет чтения, только для этой папки. На `README.TXT` для `stud` разрешено чтение.

#figure(
  image("images/5_noaccess_acl.png", width: 90%),
  caption: [Запрет stud на папку NOACCESS],
)

#figure(
  image("images/6_readme_acl.png", width: 90%),
  caption: [Чтение stud для README.TXT],
)

Из окна `stud` каталог не читается. Файл по полному пути открывается, в нём строка `rule1`.

```bash
dir D:\lab2\NOACCESS
notepad D:\lab2\NOACCESS\README.TXT
```

#figure(
  image("images/7_rule1_access.png", width: 75%),
  caption: [Проверка доступа от stud],
)

== Правило 2. Накопление разрешений

На `accumulate.txt` у `stud` чтение, у группы «Все» изменение. На `denied.txt` у `stud` запрет полного доступа, у «Все» изменение.

#figure(
  image("images/8_accumulate_acl.png", width: 90%),
  caption: [Чтение stud и изменение группы Все],
)

#figure(
  image("images/9_denied_acl.png", width: 90%),
  caption: [Запрет stud при изменении группы Все],
)

Из окна `stud` файл изменён и удалён. `denied.txt` не открылся.

```bash
type D:\lab2\acc\accumulate.txt
echo changed>> D:\lab2\acc\accumulate.txt
type D:\lab2\acc\accumulate.txt
del D:\lab2\acc\accumulate.txt
type D:\lab2\acc\denied.txt
```

#figure(
  image("images/10_rule2_access.png", width: 85%),
  caption: [Проверка накопления прав и приоритета запрета],
)

== Правило 3. Full Control и удаление файлов

Пользователь с Full Control на папку удаляет файлы в ней независимо от разрешений на сам файл: в Full Control входит удаление дочерних объектов. Набор особых разрешений R, W, X, D, P, O даёт те же отдельные права без этого удаления.

Правило проверяется на папках `fullctl` и `special`: в обеих лежит файл `locked.txt`, на котором для `stud` установлен запрет. На `fullctl` у `stud` полный доступ, на `special` -- особый набор разрешений, собранный в Проводнике без галочки «удаление подпапок и файлов».

```bash
cacls D:\lab2\fullctl
D:\lab2\fullctl BUILTIN\Администраторы:F
                NT AUTHORITY\СИСТЕМА:F
                NT AUTHORITY\Прошедшие проверку:C
                BUILTIN\Пользователи:R
                JARVIS-ONE-6\stud:(OI)(CI)F
cacls D:\lab2\fullctl\locked.txt
D:\lab2\fullctl\locked.txt JARVIS-ONE-6\stud:N
                           BUILTIN\Администраторы:F
                           NT AUTHORITY\СИСТЕМА:F
                           NT AUTHORITY\Прошедшие проверку:C
                           BUILTIN\Пользователи:R
```

#figure(
  image("images/11_special_acl.png", width: 100%),
  caption: [Особый набор разрешений stud на папку special: без «удаления подпапок и файлов»],
)

Проверка из окна `stud`: файл в `fullctl` удаляется, несмотря на запрет на самом файле; файл в `special` удалить не удаётся.

```bash
del D:\lab2\fullctl\locked.txt
del D:\lab2\special\locked.txt
```

#figure(
  image("images/12_rule3_del.png", width: 70%),
  caption: [Проверка удаления locked.txt от имени stud],
)

#figure(
  {
    set text(size: 11pt)
    table(
      columns: (1.4fr, 1.3fr, 1.5fr),
      align: (left, left, left),
      table.header([*Разрешение на папку*], [*Разрешение на файл*], [*Удаление файла*]),
      [Full Control], [No Access для stud], [да, файл удалён],
      [R, W, X, D, P, O], [No Access для stud], [нет, отказано в доступе],
    )
  },
  caption: [Удаление файла при Full Control и при особом наборе разрешений],
)

== Правило 4. Владелец

Создатель папки или файла на NTFS становится владельцем. Владельцем также может стать пользователь с Full Control или с разрешением смены владельца. Владелец читает и меняет список доступа, даже если на объекте для него стоит No Access.

В окне `stud` созданы папка `stud-dir` и файл `note.txt`: по `dir /Q` владелец обоих объектов -- `stud`. Затем `stud` запретил себе доступ к `note.txt` (`cacls ... /D stud`): чтение стало невозможным, однако владелец вернул себе доступ командой `cacls ... /E /G stud:F`.

```bash
dir /Q D:\lab2\owned\stud-dir
11.10.2026  22:10    <DIR>    JARVIS-ONE-6\stud       .
11.10.2026  22:09    <DIR>    JARVIS-ONE-6\Dingovina  ..
11.10.2026  22:10             JARVIS-ONE-6\stud       note.txt
cacls D:\lab2\owned\stud-dir\note.txt /D stud
type D:\lab2\owned\stud-dir\note.txt
Отказано в доступе.
cacls D:\lab2\owned\stud-dir\note.txt /E /G stud:F
type D:\lab2\owned\stud-dir\note.txt
owned by stud
```

#figure(
  image("images/13_rule4_stud_owner.png", width: 100%),
  caption: [stud -- владелец созданных объектов; запрет себе и возврат доступа как владельцем],
)

#figure(
  image("images/14_rule4_owner_stud.png", width: 95%),
  caption: [Владелец папки stud-dir до смены -- stud],
)

Во второй части правила демонстрируется самостоятельный захват владения: `Dingovina` не передавались никакие права, кроме одного -- особого разрешения «Смена владельца» (Take ownership, в `icacls` -- `(WO)`). Наследование на `stud-dir` отключено, в списке доступа оставлены ровно две записи, владелец по-прежнему `stud`:

```bash
icacls D:\lab2\owned\stud-dir /inheritance:r /grant "stud:F" "Dingovina:(WO)"
icacls D:\lab2\owned\stud-dir
D:\lab2\owned\stud-dir JARVIS-ONE-6\Dingovina:(WO)
                       JARVIS-ONE-6\stud:(F)
powershell -NoProfile -c "(Get-Acl 'D:\lab2\owned\stud-dir').Owner"
JARVIS-ONE-6\stud
```

#figure(
  image("images/18_wo_acl.png", width: 100%),
  caption: [Список доступа stud-dir: у Dingovina единственное право -- (WO) «Смена владельца»; владелец ещё stud],
)

Из своего сеанса `Dingovina` объект выглядит «без прав»: вкладка «Безопасность» сообщает, что для просмотра свойств нужны разрешения на чтение, а в дополнительных параметрах безопасности вместо имени владельца -- «Не удалось отобразить текущего владельца». `Dingovina` не видит даже, кто владелец, поэтому «получить» владение от исходного владельца не могла -- его можно только забрать.

#figure(
  image("images/19_wo_only_security_tab.png", width: 60%),
  caption: [Свойства stud-dir от имени Dingovina: прав на чтение нет],
)

#figure(
  image("images/20_cannot_display_owner.png", width: 85%),
  caption: [Дополнительные параметры безопасности: текущий владелец для Dingovina не отображается],
)

Кнопка «Изменить» рядом со строкой владельца меняет владельца без каких-либо дополнительных разрешений: достаточно права Take ownership. Владельцем становится `Dingovina`; Windows сразу предлагает новому владельцу заменить разрешения и выдать себе полный доступ, что и сделано.

#figure(
  image("images/21_take_owner_confirm.png", width: 95%),
  caption: [Dingovina сменила владельца кнопкой «Изменить»; Windows предлагает новому владельцу выдать себе полный доступ],
)

#figure(
  image("images/22_dingovina_owner.png", width: 60%),
  caption: [Итог: Dingovina -- владелец stud-dir с полным доступом],
)

#figure(
  {
    set text(size: 12pt)
    table(
      columns: (1.4fr, 1.2fr, 1.6fr),
      align: (left, left, left),
      table.header([*Кто*], [*Как стал владельцем*], [*Что смог сделать*]),
      [stud], [создал объект], [стал владельцем; виден в `dir /Q`],
      [Dingovina], [только Take ownership: забрала владение сама, кнопкой «Изменить»], [стала владельцем `stud-dir`, затем выдала себе Full Control],
      [владелец (stud)], [No Access на объекте не помеха], [изменил список доступа, вернул себе доступ],
    )
  },
  caption: [Владение объектом и доступ владельца к разрешениям],
)

== Замена разрешений через cacls

У всех `*.exe` в созданной иерархии запись stud с полным доступом заменяется записью Администратор с полным доступом. Это замена списка, а не добавление: ключ `/G` без `/E` заменяет весь список доступа, поэтому после команды stud в нём не остаётся.

Команда замены:

```bash
cacls D:\lab2\bin\*.exe /T /G Администратор:F
```

Ключ `/T` проходит по подкаталогам, поэтому обработаны и `bin\app.exe`, и `bin\tools\util.exe`. До и после -- вывод `cacls` по одному файлу:

```bash
cacls D:\lab2\bin\app.exe
D:\lab2\bin\app.exe BUILTIN\Администраторы:F
                    NT AUTHORITY\СИСТЕМА:F
                    NT AUTHORITY\Прошедшие проверку:C
                    BUILTIN\Пользователи:R
                    JARVIS-ONE-6\stud:F
cacls D:\lab2\bin\app.exe
D:\lab2\bin\app.exe JARVIS-ONE-6\Администратор:F
```

#figure(
  image("images/16_stud_denied.png", width: 85%),
  caption: [Запуск \*.exe от имени stud после замены -- отказано в доступе],
)

#figure(
  image("images/17_admin_runs.png", width: 85%),
  caption: [Запуск \*.exe от имени Администратора после замены],
)

#figure(
  {
    set text(size: 12pt)
    table(
      columns: (1fr, 1.4fr, 1.4fr),
      align: (left, left, left),
      table.header([*Файл*], [*Список доступа до*], [*Список доступа после*]),
      [`app.exe`], [`stud:F` + наследуемые записи], [`Администратор:F`],
      [`util.exe`], [`stud:F` + наследуемые записи], [`Администратор:F`],
    )
  },
  caption: [Замена разрешений stud на Администратор для файлов exe],
)

Проверка запуска: у `stud` оба файла дают «Отказано в доступе», у `Администратор` оба выполняются.

= Выводы

+ Разрешения, установленные на файл, определяют доступ сильнее, чем разрешения на папку: при запрете на папке `NOACCESS` файл `README.TXT` с разрешением на чтение открывается по полному пути.
+ Разрешения пользователя и его групп складываются, но любой запрет (No Access) отменяет всё накопленное: для `stud` с явным запретом доступ отсутствовал независимо от разрешений групп.
+ Full Control на папку позволяет удалять в ней файлы вопреки запрету на самом файле -- в это разрешение входит право «удаление подпапок и файлов». Особый набор R, W, X, D, P, O без этого права удалять такие файлы не позволяет.
+ Владелец объекта -- его создатель; владелец видит и меняет список доступа даже при полном запрете себе доступа, а учётная запись с Full Control на родительскую папку может сменить владельца объекта.
+ `cacls` с ключом `/G` без `/E` заменяет весь список доступа -- запись stud исчезла из ACL всех `*.exe`; с ключом `/E` запись была бы добавлена к существующим.
