# Kuno Banner

[ENGLISH](README.md) | **ESPAÑOL**

Mantenido por Criptonautas. Sin afiliación ni respaldo de Discourse (Civilized Discourse Construction Kit, Inc.).

Un aviso descartable en la portada que cambia cada día y muestra un tema del foro (de una
etiqueta o categoría elegidas) o una recaudación externa de Monero en
[Kuno](https://codeberg.org/nebras/kuno) que apoya la comunidad. Hecho para el tema
[Horizon](https://meta.discourse.org/t/horizon-theme/360486).

## Qué hace

- **Un solo grupo, un elemento al día.** Los temas con `kuno_tag` o de `kuno_categories`
  (los más antiguos primero, cada uno una vez) seguidos de las URLs de `supported_kunos`. Todos ven el mismo elemento el
  mismo día UTC; al día siguiente avanza un paso y vuelve a empezar al final.
- **Imagen a la izquierda, texto a la derecha.** La imagen destacada a la izquierda (el
  avatar de `system` si no hay); a la derecha, la línea de título con el estilo de los
  títulos de las tarjetas de Horizon y hasta tres líneas de descripción. Padding, un
  fondo neutro un paso distinto del de las tarjetas, su borde y su hover.
- **Línea de título:** `[KUNO]` y el título del tema o de la página del Kuno. Un Kuno
  sin vista previa (visitantes sin sesión) muestra `kuno_banner.supporting` en su lugar,
  con su URL como descripción. Ambos textos son editables en las traducciones del
  componente.
- **Temas:** el extracto del tema como descripción. Sin imagen del tema: el fondo de la
  categoría, luego su logo, luego la imagen opengraph del sitio. Armado desde la lista de
  temas, así que lo ve todo el mundo.
- **Kunos apoyados:** imagen, título y descripción tomados del onebox de Discourse de la
  página del Kuno, para miembros con sesión. Abre en otra
  pestaña. Solo se aceptan URLs `https://`.
- **Toda la tarjeta es clicable**, como las tarjetas de tema de Horizon; solo el botón de
  cerrar queda por encima del enlace.
- **Descartable.** El botón de cerrar oculta el aviso en ese navegador hasta el elemento
  del día siguiente. Funciona también para visitantes sin sesión.
- **Solo en la portada**, sobre la lista de temas y con el mismo ancho que las tarjetas
  de tema de Horizon. Si el grupo está vacío no se muestra nada.

## Ajustes

| Ajuste | Por defecto | |
|---|---|---|
| `kuno_tag` | `kuno` | Etiqueta cuyos temas entran en la rotación. Vacío para mostrar solo Kunos apoyados. |
| `kuno_categories` | vacío | Categorías cuyos temas entran en la rotación. Se deja fuera su tema «Acerca de». |
| `kuno_title_max_length` | `100` | Los títulos de Kunos apoyados se cortan con `…` tras esta cantidad de caracteres. |
| `supported_kunos` | vacío | URLs de recaudaciones externas de Kuno. |

El texto del aviso está en las traducciones del componente (`kuno_banner.supporting`).

## Límites

- **Las vistas previas de Kuno necesitan sesión.** El endpoint `/onebox` de Discourse
  exige iniciar sesión, así que los visitantes sin sesión solo ven la URL del Kuno.
- **Sin datos en vivo de Kuno.** Kuno no publica API ni feed: el progreso de la
  recaudación nunca se muestra.
- **Los temas privados siguen privados.** Los temas se leen de las listas de etiqueta y categoría como
  el visitante, así que quien no puede ver un tema no lo recibe en su rotación, y su
  elemento del día puede ser otro.

## Instalación

**Admin → Apariencia → Temas y componentes → Instalar**, desde la URL de este
repositorio, y añádelo a Horizon.

## Desarrollo

`pnpm install && pnpm lint`. CI también corre los tests QUnit de `test/` y el spec de
funciones básicas del núcleo. Las notas para contribuir están en [AGENTS.md](AGENTS.md).

## Licencia

MIT. Ver [LICENSE](LICENSE).

Texto de este README bajo [CC BY-NC-SA 4.0](CC-BY-NC-SA-4.0.txt).
