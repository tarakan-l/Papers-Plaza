Задание 1, 2, 3
Делаем транзакцию А, не коммитим

<img width="703" height="550" alt="image" src="https://github.com/user-attachments/assets/6593c2a3-fa2b-4434-b7a2-3e16e8297233" />


Понял, что t_infomask - битовая маска хранящая состояние строки, биты являются флагами дающие сведения о состоянии строки

Теперь, пока нет комммита выполняем запрос Б

<img width="694" height="319" alt="image" src="https://github.com/user-attachments/assets/cbbce569-0ad4-483f-821c-e298c6bb46d5" />


коммитим А и в Б теперь получаем изменение маски так как строки освобождены

<img width="697" height="362" alt="image" src="https://github.com/user-attachments/assets/7240b635-904b-4642-8aba-642370f1249f" />

Задание 4
Начинаем транзакцию А

<img width="660" height="233" alt="image" src="https://github.com/user-attachments/assets/057a77bd-7944-4d80-9f6a-7a3461cf02ab" />

Начинаем транзакцию Б

<img width="629" height="269" alt="image" src="https://github.com/user-attachments/assets/f4c1a8c7-0ad6-4308-9771-6476f62c27fa" />

Запрашиваем строку Б в А

<img width="700" height="374" alt="image" src="https://github.com/user-attachments/assets/e71fe045-9d9c-4724-9136-4c6535767088" />

Запрашиваем строку А в Б и ловим ошибку

<img width="851" height="540" alt="image" src="https://github.com/user-attachments/assets/30f7dfb8-1f5d-4faf-991b-f97487712c6a" />

После того как Deadlock отловлен Postgre пожертвовал транзакцию Б и отменил её, чтобы отлочить строку Б

Задание 5
Без share

Транзакция А (ждет коммита)

<img width="758" height="425" alt="image" src="https://github.com/user-attachments/assets/f1b9ccdd-434a-47a4-8f18-fcc67c2696c1" />

Транзакция Б (ждет строки)

<img width="723" height="250" alt="image" src="https://github.com/user-attachments/assets/4d14c50d-2948-49a4-8c93-2533b2468a6a" />

не работает получается...
а теперь с SHARE:
Транзакция А (ждет коммита)

<img width="671" height="433" alt="image" src="https://github.com/user-attachments/assets/8a7691b6-ce31-4393-87c0-dd062841c71d" />

Транзакция Б (не ждем строки - она не локнулась для чтения)

<img width="698" height="438" alt="image" src="https://github.com/user-attachments/assets/843631ef-7d51-494b-a385-59c85e90f30b" />

Транзакция Б (теперь пытаемся изменить Updateoм строку но не можем)

<img width="981" height="621" alt="image" src="https://github.com/user-attachments/assets/c2758bc9-aed5-46a6-b76d-d81f2402dbcf" />

Видим что у нас есть lock по конфликтам

<img width="778" height="541" alt="image" src="https://github.com/user-attachments/assets/e2414f05-394b-4475-826e-88b8e6c50c71" />


Задание 6

Запускам анализ и видим кучу строк где xmax ~= 0

<img width="696" height="726" alt="image" src="https://github.com/user-attachments/assets/dbd99471-8d52-4013-b5be-a7c2b3e0fd9f" />

Вакуумируем и слушаем результат

<img width="670" height="250" alt="image" src="https://github.com/user-attachments/assets/45df2149-7fe7-4e46-8b1d-4ec9e568b57b" />
