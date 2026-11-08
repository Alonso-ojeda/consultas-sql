# Taller SQL — versión reorganizada

Este repositorio reúne **cinco escenarios independientes** para practicar consultas de MySQL 8.0.16 o posterior. En cada carpeta se incluye el script de creación y carga de datos, un archivo con los ejercicios resueltos y una imagen con el diagrama de las relaciones.

## Organización

| Carpeta | Tema | Archivos principales |
| --- | --- | --- |
| `01_HelpDesk_Pro` | Mesa de ayuda, tickets y técnicos | `01_base_datos.sql`, `consultas.sql` |
| `02_AssetControl` | Inventario, responsables y mantenimiento | `02_base_datos.sql`, `consultas.sql` |
| `03_CompraFacil` | Solicitudes, compras y entregas | `03_base_datos.sql`, `consultas.sql` |
| `04_TalentTrack` | Formación, matrículas y asistencias | `04_base_datos.sql`, `consultas.sql` |
| `05_SpaceBook` | Salas, reservas, asistentes y recursos | `05_base_datos.sql`, `consultas.sql` |

El archivo `01_examen_MySQL_I.md` se mantiene como material de referencia del examen, sin soluciones adicionales.

## Ejecución en MySQL Workbench

1. Abrir el archivo `*_base_datos.sql` del escenario deseado y **ejecutarlo completo**. Esta operación elimina y vuelve a crear la base correspondiente.
2. Abrir `consultas.sql` dentro de esa misma carpeta.
3. Ejecutar las consultas individualmente para observar los resultados; también se puede ejecutar el script completo.
4. Repetir con las demás bases si se quieren probar todos los escenarios.

**Importante:** Los datos de prueba y las definiciones de las tablas se conservaron; por eso los scripts de carga no deben usarse sobre bases reales. Algunas consultas usan nombres de salida con prefijo `resultado_` para distinguir los alias de las columnas físicas.

## Criterios usados en la revisión

- Mantener claves foráneas, tipos, restricciones y datos semilla para no modificar la información disponible.
- Adoptar una presentación de SQL con palabras clave en minúscula, nombres de referencia más descriptivos y separación visual de cláusulas.
- Explicitar los `inner join` y mantener los `left join` cuando se requiere incluir filas sin coincidencia.
- Respetar los ejercicios 18–20 que solicitan subconsultas: no se reemplazaron por JOINs aunque algunas admitan alternativas.
- Mantener `group by`, agregaciones, filtros, límites y criterios de ordenamiento, porque cambiarlos puede alterar los resultados.

## Pruebas y alcance

La revisión automatizada comprueba la presencia y cantidad de ejercicios y compara los scripts de carga con los archivos fuente después de eliminar comentarios y normalizar mayúsculas/minúsculas de las palabras clave. **No incluye una prueba real contra un servidor MySQL**, por lo que conviene ejecutar cada consulta en Workbench y comparar las filas antes de entregar.

Las consultas y el enunciado proceden del material proporcionado como punto de partida. La reorganización de estilo no convierte por sí sola ese material en un trabajo de autoría independiente; revisa y comprende cada respuesta y aplica las reglas de atribución de tu curso.
