<img width="445" height="188" alt="image" src="https://github.com/user-attachments/assets/fe1b7cb6-deed-4a2a-99c4-04d104e22ae6" />1. CTE

1.1 Получение количества преступлений у преступников
```
with criminals as
    (select biometryid, count(crimeid) as crimeCount
         from criminal.record
         group by biometryid)

select fullname, crimeCount
from criminals
join identity.passport on biometry = criminals.biometryid;
```
<img width="411" height="104" alt="image" src="https://github.com/user-attachments/assets/0ec5d029-762b-4c48-88b5-a2accbf63a90" />

1.2 Альтернативное получение всех предметов через временную таблицу
```
with uselessItems as
    (select itemname
     from items.luggageitemtype)

select uselessItems from uselessItems;
```
<img width="210" height="114" alt="image" src="https://github.com/user-attachments/assets/0f912bd2-4b49-46e6-925c-e4edefc3b5cc" />

2. UNION, INTERSECT, EXCEPT запросики

2.1 Union

2.1.1 Объединение всех типов преступлений и предметов в одну таблицу
```
select *
from criminal.casetype
union 
select *
from items.luggageitemtype;
```
<img width="456" height="383" alt="image" src="https://github.com/user-attachments/assets/ba3625c0-c898-411c-9e1f-635bf02a6ae0" />

2.2 Intersect

2.2.1 Получение всех преступлений из массива и фильтрация их по другой таблице
```
select *
from criminal.casetype
where id in (1, 3)
intersect
select *
from criminal.casetype
where id = 3;
```
<img width="449" height="61" alt="image" src="https://github.com/user-attachments/assets/0d70c625-66f2-4566-8423-808c646c3be7" />


2.3 Except

2.3.1 Получение всех типов преступлений кроме тех, у которых id между 3 и 6
```
select *
from criminal.casetype
except 
select *
from criminal.casetype
where id between 3 and 6;
```
<img width="442" height="201" alt="image" src="https://github.com/user-attachments/assets/d4747155-0ea9-4c2d-94c5-4993e7a8502d" />

3. Partition by

3.1 Выборка всех типов преступлений по Id и количество совершенных случаев этих преступлений
```
select distinct 
    casetype_id,
    count (*) over (partition by casetype_id)
from criminal.case;
```
<img width="387" height="184" alt="image" src="https://github.com/user-attachments/assets/7ad5d559-e49c-47a2-b0ed-3dc7d0fc872e" />

4. Partition by + order by

5. Pows and range

5.1 Получение всех случаев преступлений и значения равному сумму типов преступлений в двух столбцах до этого и этого столбца
```
select 
    id,
    sum (casetype_id) over (rows between 2 preceding and current row )
from criminal.case;
```
<img width="289" height="295" alt="image" src="https://github.com/user-attachments/assets/910a1a77-c656-401c-80f0-3ff80363fcb9" />

6. Функции смещения

6.1 Получение первого номера случая по какому то типуц преступлений
```
select distinct 
    casetype_id,
    first_value(id) over (partition by casetype_id order by id)
from criminal.case;
```
<img width="445" height="188" alt="image" src="https://github.com/user-attachments/assets/5f978af0-d003-4c91-8367-d8babcd01094" />


