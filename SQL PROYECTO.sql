--1.Ingresos por genero - Comparación de los ingresos
--totales generados por clientes hombres frentea mujeres

select sexo, sum(monto_de_compra) as TotalComprado
from cliente
group by sexo


--2.Usuarios de descuentos con alto gasto - Identificación de clientes que
--utilizaron descuentos pero cuyo gasto superó el importe medio de compra.
SELECT IDCLIENTE, monto_de_compra
FROM CLIENTE
WHERE descuento_aplicado='YES' AND monto_de_compra>=(SELECT AVG(monto_de_compra) FROM CLIENTE)



--59 ES EL PROMEDIO
SELECT AVG(monto_de_compra) FROM CLIENTE


--3. los 5 productos mejor valorados
-- Identificación de los productos con las valoraciones (COMENTARIOS) medias más altas.

SELECT TOP 5 articulo_comprado,
		CAST(AVG(calificacion_del_cliente) as DECIMAL (10,2)) AS promedio_calificacion_cliente
FROM cliente
GROUP BY articulo_comprado
ORDER BY CAST(AVG(calificacion_del_cliente) AS DECIMAL(10,2)) DESC

--4. Comparación de tipos de envío 
--Comparación de los importes medios de compra entre envíos estándar y exprés.

select tipo_de_envio, 
ROUND(AVG(monto_de_compra),2) as Promedio_monto_de_compra
from cliente
where tipo_de_envio in ('Standard','Express')
group by tipo_de_envio

--5. Suscriptores frente a no suscriptores 
-- Comparación del gasto medio y los ingresos totales según el estado de suscripción.

SELECT estado_de_suscripcion,
       COUNT(idcliente) AS total_de_clientes,
       ROUND(AVG(monto_de_compra),2) AS Gastomedio,
       ROUND(SUM(monto_de_compra),2) AS ingresototal
FROM cliente
GROUP BY estado_de_suscripcion
ORDER BY ingresototal,Gastomedio DESC;

--6. Productos con alta dependencia de descuentos
--- Identificación de los 5 productos con mayor porcentaje de compras realizadas con descuento.

SELECT TOP 5
       articulo_comprado,
       ROUND(
           100.0 * SUM(CASE WHEN descuento_aplicado = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
           2
       ) AS Tasa_de_descuento
FROM cliente
GROUP BY articulo_comprado
ORDER BY Tasa_de_descuento DESC;

--7.Segmentación de clientes
--Clasificación de los clientes en segmentos (nuevos, recurrentes y fieles)
--según su historial de compras

with tipo_cliente as (
SELECT idcliente, compras_anteriores,
CASE 
    WHEN compras_anteriores = 1 THEN 'Nuevo'
    WHEN compras_anteriores BETWEEN 2 AND 10 THEN 'Recurrente'
    ELSE 'Leal'
    END AS Segmento_CLiente
FROM cliente)

select Segmento_CLiente,count(*) AS "Numero de clientes" 
from tipo_cliente 
group by Segmento_CLiente;

--8. Los 3 mejores productos por categoría 
--Listado de los productos más comprados en cada categoría.

WITH CUENTADEARTICULOS AS(
SELECT CATEGORIA,
       articulo_comprado,
	   COUNT(IDCLIENTE) AS TOTAL_DE_PEDIDOS,
	   ROW_NUMBER() OVER(PARTITION BY CATEGORIA ORDER BY COUNT(IDCLIENTE) DESC) AS RANKING_DE_PRODUCTOS
FROM CLIENTE
GROUP BY CATEGORIA,ARTICULO_COMPRADO

)
SELECT RANKING_DE_PRODUCTOS,CATEGORIA,ARTICULO_COMPRADO,TOTAL_DE_PEDIDOS
FROM CUENTADEARTICULOS
WHERE RANKING_DE_PRODUCTOS<=3

--9. Clientes recurrentes y suscripciones 
-- Análisis de si los clientes con más de 5 compras tienen mayor probabilidad de suscribirse

select estado_de_suscripcion,
       count(idcliente) as Compras_recurrentes
from cliente
where compras_anteriores>5
group by estado_de_suscripcion

