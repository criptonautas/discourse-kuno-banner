# Kuno Banner

[ENGLISH](README.md) | **ESPAÑOL**

Mantenido por Criptonautas. Sin afiliación ni respaldo de Discourse (Civilized Discourse Construction Kit, Inc.).

Un aviso descartable en la portada que cambia cada día y muestra un tema del foro con
una etiqueta elegida o una recaudación externa de Monero en
[Kuno](https://codeberg.org/nebras/kuno) que apoya la comunidad. Hecho para el tema
[Horizon](https://meta.discourse.org/t/horizon-theme/360486).

## Qué hace

- **Un solo grupo, un elemento al día.** Los temas con `kuno_tag` (los más antiguos
  primero) seguidos de las URLs de `supported_kunos`. Todos ven el mismo elemento el
  mismo día UTC; al día siguiente avanza un paso y vuelve a empezar al final.
- **Como un post:** el avatar de `system` a la izquierda y el texto con un onebox a
  la derecha, en una tarjeta con el estilo de las tarjetas de tema de Horizon.
- **Título arriba, onebox debajo.** Las dos tarjetas usan los estilos de onebox del
  núcleo, así que se ven como los oneboxes de las publicaciones.
- **Temas etiquetados:** el título del tema arriba; debajo, un onebox con su categoría,
  imagen y extracto cuando la lista de temas los trae.
- **Kunos apoyados:** *"¡Atención! Estamos apoyando este Kuno externo:"* arriba; debajo,
  el onebox real (título, imagen y descripción de la página del Kuno) para miembros con
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
| `supported_kunos` | vacío | URLs de recaudaciones externas de Kuno. |

El texto del aviso está en las traducciones del componente (`kuno_banner.supporting`).

## Límites

- **El onebox necesita sesión.** El endpoint `/onebox` de Discourse exige iniciar
  sesión, así que los visitantes sin sesión ven la tarjeta simple.
- **Sin datos en vivo de Kuno.** Kuno no publica API ni feed: el progreso de la
  recaudación nunca se muestra, y la tarjeta simple solo muestra la URL.
- **Las etiquetas privadas siguen privadas.** Los temas se leen de `/tag/<tag>.json` como
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
