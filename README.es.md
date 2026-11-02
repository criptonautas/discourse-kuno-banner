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
- **Como un post:** el avatar de `system` a la izquierda y el texto con un onebox a
  la derecha, en una tarjeta con el estilo de las tarjetas de tema de Horizon.
- **Línea de título** con el estilo de los títulos de las tarjetas de Horizon: `[KUNO]`
  y el título del tema, o `[KUNO]` y `kuno_banner.supporting` para un Kuno apoyado
  (ambos editables en las traducciones del componente). Un onebox debajo, con los
  estilos de onebox del núcleo.
- **Temas:** un onebox con la imagen y el extracto del tema (el título ya está arriba),
  armado desde la lista de temas, así que lo ve todo el mundo. Sin imagen del tema: el fondo de la
  categoría, luego su logo, luego la imagen opengraph del sitio.
- **Toda la tarjeta es clicable**, a través del enlace del título.
- **Kunos apoyados:** el onebox real (título, imagen y descripción de la página del Kuno) para miembros con
  sesión, o una tarjeta simple con el enlace para el resto. Los enlaces abren en otra
  pestaña. Solo se aceptan URLs `https://`.
- **Descartable.** El botón de cerrar oculta el aviso en ese navegador hasta el elemento
  del día siguiente. Funciona también para visitantes sin sesión.
- **Solo en la portada**, sobre la lista de temas y con el mismo ancho que las tarjetas
  de tema de Horizon. Si el grupo está vacío no se muestra nada.

## Ajustes

| Ajuste | Por defecto | |
|---|---|---|
| `kuno_tag` | `kuno` | Etiqueta cuyos temas entran en la rotación. Vacío para mostrar solo Kunos apoyados. |
| `kuno_categories` | vacío | Categorías cuyos temas entran en la rotación. Se deja fuera su tema «Acerca de». |
| `supported_kunos` | vacío | URLs de recaudaciones externas de Kuno. |

El texto del aviso está en las traducciones del componente (`kuno_banner.supporting`).

## Límites

- **El onebox necesita sesión.** El endpoint `/onebox` de Discourse exige iniciar
  sesión, así que los visitantes sin sesión ven la tarjeta simple.
- **Sin datos en vivo de Kuno.** Kuno no publica API ni feed: el progreso de la
  recaudación nunca se muestra, y la tarjeta simple solo muestra la URL.
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
