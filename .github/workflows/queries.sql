select COUNT(customer_id) as customers_count
from customers c;
-- В select выводим поле customer_id, агрегируем его с помощью функции COUNT,
-- считаем общее количество покупателей, присваиваем as
-- From - выводим таблицу из которой берем данные