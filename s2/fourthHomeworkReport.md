Задание 1, 2, 3
Делаем транзакцию А, не коммитим

<img width="703" height="550" alt="image" src="https://github.com/user-attachments/assets/6593c2a3-fa2b-4434-b7a2-3e16e8297233" />


Понял, что t_infomask - битовая маска хранящая состояние строки, биты являются флагами дающие сведения о состоянии строки

Теперь, пока нет комммита выполняем запрос Б

<img width="694" height="319" alt="image" src="https://github.com/user-attachments/assets/cbbce569-0ad4-483f-821c-e298c6bb46d5" />


коммитим А и в Б теперь получаем изменение маски так как строки освобождены

<img width="697" height="362" alt="image" src="https://github.com/user-attachments/assets/7240b635-904b-4642-8aba-642370f1249f" />

