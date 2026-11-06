# Conectores de Visor

Las recetas que usa [Visor](https://github.com/atraverso06) para mostrar en su isla avisos de servicios web (GitHub…) y de apps de Windows (WhatsApp, Discord, LinkedIn, Instagram, Teams, Slack, Telegram, Outlook, Signal, Notion, Enlace móvil). Visor descarga este catálogo solo, desde el último release: sumar o arreglar un conector no exige una versión nueva de la app.

Por ahora solo el autor de Visor publica conectores.

## Qué hay acá

```
connectors/
  github/     connector.json + logo.png
  whatsapp/   connector.json + logo.png   (app de Windows, motor 3)
  discord/    connector.json + logo.png   (app de Windows, motor 3)
  linkedin/   connector.json + logo.png   (app de Windows, motor 3)
  instagram/  connector.json + logo.png   (app de Windows, motor 3)
  teams/      connector.json + logo.png   (app de Windows, motor 3)
  slack/      connector.json + logo.png   (app de Windows, motor 3)
  telegram/   connector.json + logo.png   (app de Windows, motor 3)
  outlook/    connector.json + logo.png   (app de Windows, motor 3)
  signal/     connector.json + logo.png   (app de Windows, motor 3)
  notion/     connector.json + logo.png   (app de Windows, motor 3)
  phonelink/  connector.json + logo.png   (app de Windows, motor 3)
build/pack.ps1               arma el zip y catalog.json de un release
.github/workflows/release.yml  publica el release al subir un tag
```

Cada carpeta de `connectors/` es un conector: un `connector.json` (JSON con comentarios) y su logo en PNG. Una receta **solo lee**: hace pedidos GET a la dirección que declara, que tiene que estar entre sus `domains`, con la clave que el usuario le dio a Visor. Las claves quedan en el Administrador de credenciales de Windows, nunca en este repositorio ni en archivos de Visor.

## Una receta (motor 1)

| Campo | Qué es |
|---|---|
| `id`, `name`, `type`, `version`, `author` | Quién es: id estable, nombre, tipo ("Código"), versión de la receta y autor |
| `engine` | La versión del motor de Visor que necesita. Un Visor más viejo la ignora |
| `logo` | El PNG al lado del `connector.json` |
| `rank` | Opcional: dónde va en Ajustes › Conectores, por uso (menor, antes; Claude Code es 1 y Codex 2, en Visor). Sin `rank`, al final por nombre |
| `auth` | `{"kind": "none"}`; `{"kind": "key", "header", "format" (ej. `Bearer {key}`), "label", "help"}`; o, desde el motor 2, `{"kind": "device", "client", "scope", "code", "token", "header", "format"}`: inicio de sesión en el navegador con un código (OAuth *device flow*), con `code` y `token` https y entre sus `domains` |
| `can`, `cannot` | Lo que puede y lo que no, tal como lo muestra la tarjeta "Conectar" (✓ y ✗) |
| `translations` | Opcional: `{"en": {"name", "type", "can", "cannot", "maps"}}`, las palabras en otro idioma. Lo que falta queda en español, y un Visor viejo lo ignora, así que no pide un motor nuevo |
| `domains` | Los únicos dominios a los que puede preguntar |
| `read` | `url` (https), `every` (segundos, al menos 60), `format` (`json` o `feed`: RSS 2.0 o Atom), `headers`, `items` (el camino a la lista) |
| `item` | `id`, `title`, `text`, `open`: plantillas con `{camino.con.puntos}` y `{campo:mapa}` |
| `maps` | Palabras para los valores de un campo; `*` es el resto |

## Una app de Windows (motor 3)

Una receta con `"source": "windows"` no lee ningún servicio: muestra en la isla las notificaciones de Windows de una app instalada, como "Elegir apps" en Visor (que deja de listarla). No lleva `auth`, `domains`, `read`, `item` ni `maps`.

| Campo | Qué es |
|---|---|
| `source` | `"windows"` |
| `windowsApps` | Los AppUserModelID de la app (al menos uno), como los muestra `Get-StartApps` |
| `install` | Una página https donde conseguir la app: la tarjeta "Conectar" muestra "Instalar" si no está en la PC |
| `logo` | Se usa solo si la app no está instalada; si está, Visor usa su ícono de Windows |

En una receta web, `windowsApps` dice lo contrario: las apps de Windows cuyas notificaciones se dejan afuera mientras el conector está conectado, para que nada salga dos veces.

## Publicar

1. Cambiar o agregar la carpeta del conector (y subir `version` de la receta).
2. Subir un tag con la fecha: `git tag v2026.11.4 && git push origin v2026.11.4`.
3. El workflow arma `connectors-<versión>.zip` y `catalog.json` (versión, motor y SHA-256 del zip) y los publica. Visor lo baja en el día, comprueba la huella y reemplaza su copia; si algo falla, se queda con la anterior.

Para probar el paquete sin publicar: `./build/pack.ps1 -Version 2026.11.4` (queda en `artifacts/connectors/`).

## Marcas

Los logos son marcas de sus dueños y se usan solo para identificar cada servicio o app.

## Licencia

Las recetas y los scripts están bajo licencia MIT ([LICENSE](LICENSE)). Los logos y los nombres de las apps y servicios no entran en ella.
