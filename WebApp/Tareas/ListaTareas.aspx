<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ListaTareas.aspx.cs" Inherits="Gestion_Tareas.WebApp.Tareas.ListaTareas" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>GestorTareas — Tareas</title>

    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;600;700&family=Source+Sans+3:wght@300;400;600&display=swap" rel="stylesheet" />
    <link href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.min.css" rel="stylesheet" />
    <link href="../Styles/site.css" rel="stylesheet" />
</head>
<body>
<form id="form1" runat="server">

    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" />

    <nav class="gt-navbar">
        <span class="brand">Gestor<span>Tareas</span></span>
        <div class="nav-links">
            <a href="../Proyectos/ListaProyectos.aspx">Proyectos</a>
            <a href="ListaTareas.aspx" class="active">Tareas</a>
            <a href="../Usuarios/ListaUsuarios.aspx">Usuarios</a>
        </div>
        <div class="nav-user">
            Bienvenido, <strong><span id="lblUsuario"></span></strong>
            &nbsp;|&nbsp;
            <a href="#" onclick="cerrarSesion()">Salir</a>
        </div>
    </nav>

    <div class="gt-main">

        <div class="flex-between mb-2">
            <h2>Gestión de Tareas</h2>
            <button type="button" class="gt-btn gt-btn-primary"
                    onclick="window.location.href='FormTarea.aspx'">
                &#43; Nueva Tarea
            </button>
        </div>

        <div id="gt-alertas"></div>

        <!-- Filtros -->
        <div class="gt-filters">
            <div class="gt-form-group">
                <label for="fProyecto">Proyecto</label>
                <select id="fProyecto" title="Filtra tareas por proyecto">
                    <option value="">— Todos —</option>
                </select>
            </div>
            <div class="gt-form-group">
                <label for="fTitulo">Título</label>
                <input type="text" id="fTitulo" placeholder="Buscar por título..."
                       title="Filtra tareas por título" />
            </div>
            <div class="gt-form-group">
                <label for="fAsignado">Asignado a</label>
                <select id="fAsignado" title="Filtra tareas por usuario asignado">
                    <option value="">— Todos —</option>
                </select>
            </div>
            <div class="gt-form-group">
                <label for="fEstado">Estado</label>
                <select id="fEstado" title="Filtra tareas por estado">
                    <option value="">— Todos —</option>
                </select>
            </div>
            <div class="gt-form-group" style="min-width:auto;">
                <label>&nbsp;</label>
                <button type="button" class="gt-btn gt-btn-primary" onclick="buscar()">Buscar</button>
            </div>
            <div class="gt-form-group" style="min-width:auto;">
                <label>&nbsp;</label>
                <button type="button" class="gt-btn gt-btn-ghost" onclick="limpiar()">Limpiar</button>
            </div>
        </div>

        <!-- Tabla -->
        <div class="gt-card">
            <div class="gt-table-wrap">
                <table class="gt-table">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Proyecto</th>
                            <th>Título</th>
                            <th>Asignado a</th>
                            <th>Estado</th>
                            <th>Fecha Límite</th>
                            <th>Comentarios</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody id="tblBody">
                        <tr>
                            <td colspan="8" style="text-align:center;color:var(--text-muted);padding:2rem;">
                                Cargando tareas...
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

    </div>

    <!-- ── Diálogo de Comentarios ── -->
    <div id="dlgComentarios" title="Comentarios de la Tarea" style="display:none;">
        <div id="listaComentarios" style="max-height:280px;overflow-y:auto;margin-bottom:1rem;">
            <p class="text-muted" style="text-align:center;padding:1rem;">Cargando...</p>
        </div>
        <div style="border-top:1px solid var(--border);padding-top:0.75rem;">
            <label style="font-size:0.8rem;font-weight:600;color:var(--text-label);text-transform:uppercase;letter-spacing:0.06em;">
                Nuevo comentario
            </label>
            <textarea id="txtComentario" rows="3"
                      style="width:100%;margin-top:0.4rem;background:var(--bg-input);border:1px solid var(--border);border-radius:6px;color:var(--text);padding:0.5rem;font-family:inherit;resize:vertical;"
                      placeholder="Escriba su comentario aquí..."
                      title="Escriba el comentario que desea agregar a esta tarea"></textarea>
            <div style="text-align:right;margin-top:0.5rem;">
                <button type="button" class="gt-btn gt-btn-primary gt-btn-sm" onclick="agregarComentario()">
                    &#10003; Agregar
                </button>
            </div>
        </div>
    </div>

    <!-- Diálogo confirmación cancelar tarea -->
    <div id="dlgCancelar" title="Confirmar cancelación" style="display:none;">
        <p>¿Está seguro de que desea cancelar esta tarea? Se marcará como <strong>Cancelada</strong>.</p>
    </div>

</form>

<script src="https://code.jquery.com/jquery-1.12.4.min.js"></script>
<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
<script src="../Scripts/app.js"></script>

<script>
    var _tareaIdComentario = 0;
    var _tareaIdCancelar   = 0;

    $(function () {
        PageMethods.ObtenerNombreSesion(function (n) { $("#lblUsuario").text(n); });
        cargarCombos();
    });

    function cargarCombos() {
        PageMethods.ObtenerCatalogos(function (cat) {
            $.each(cat.Proyectos, function (i, p) {
                $("#fProyecto").append('<option value="' + p.Id + '">' + p.Descripcion + '</option>');
            });
            $.each(cat.Usuarios, function (i, u) {
                $("#fAsignado").append('<option value="' + u.Id + '">' + u.Descripcion + '</option>');
            });
            $.each(cat.EstadosTarea, function (i, e) {
                $("#fEstado").append('<option value="' + e.Id + '">' + e.Descripcion + '</option>');
            });

            // Si viene filtro de proyecto por querystring
            var qProy = obtenerQueryParam("proyectoId");
            if (qProy) { $("#fProyecto").val(qProy); }

            buscar();
        });
    }

    function buscar() {
        var proyId   = $("#fProyecto").val() ? parseInt($("#fProyecto").val()) : null;
        var titulo   = $.trim($("#fTitulo").val()) || null;
        var asignado = $("#fAsignado").val() ? parseInt($("#fAsignado").val()) : null;
        var estadoId = $("#fEstado").val()   ? parseInt($("#fEstado").val())   : null;

        PageMethods.Consultar(proyId, titulo, asignado, estadoId,
            function (lista) {
                var tbody = $("#tblBody");
                tbody.empty();

                if (!lista || lista.length === 0) {
                    tbody.append('<tr><td colspan="8" style="text-align:center;color:var(--text-muted);padding:2rem;">No se encontraron tareas.</td></tr>');
                    return;
                }

                $.each(lista, function (i, t) {
                    var asignadoTxt = t.AsignadoANombre
                        ? t.AsignadoANombre
                        : '<span class="text-muted">Sin asignar</span>';

                    var fechaLim = t.FechaLimiteStr
                        ? t.FechaLimiteStr
                        : '<span class="text-muted">—</span>';

                    var acciones =
                        '<div class="actions">' +
                        '<button type="button" class="gt-btn gt-btn-ghost gt-btn-sm" ' +
                        'onclick="verComentarios(' + t.TareaId + ')" title="Ver y agregar comentarios">&#128172; (' + t.TotalComentarios + ')</button>' +
                        '<button type="button" class="gt-btn gt-btn-ghost gt-btn-sm" ' +
                        'onclick="editar(' + t.TareaId + ')" title="Editar tarea">&#9998; Editar</button>' +
                        '<button type="button" class="gt-btn gt-btn-danger gt-btn-sm" ' +
                        'onclick="confirmarCancelar(' + t.TareaId + ')" title="Cancelar tarea">&#10005; Cancelar</button>' +
                        '</div>';

                    tbody.append(
                        '<tr>' +
                        '<td>' + (i + 1) + '</td>' +
                        '<td>' + t.ProyectoNombre + '</td>' +
                        '<td><strong>' + t.Titulo + '</strong></td>' +
                        '<td>' + asignadoTxt + '</td>' +
                        '<td>' + gtBadge(t.EstadoTareaNombre) + '</td>' +
                        '<td>' + fechaLim + '</td>' +
                        '<td style="text-align:center;">' + t.TotalComentarios + '</td>' +
                        '<td>' + acciones + '</td>' +
                        '</tr>'
                    );
                });
            },
            function () { gtMostrarAlerta("error", "Error al cargar tareas."); }
        );
    }

    function limpiar() {
        $("#fProyecto, #fAsignado, #fEstado").val("");
        $("#fTitulo").val("");
        buscar();
    }

    function editar(id) {
        window.location.href = "FormTarea.aspx?id=" + id;
    }

    /* ── Comentarios ── */
    function verComentarios(tareaId) {
        _tareaIdComentario = tareaId;
        $("#txtComentario").val("");
        $("#listaComentarios").html('<p class="text-muted" style="text-align:center;padding:1rem;">Cargando...</p>');

        $("#dlgComentarios").dialog({
            modal: true, width: 520, resizable: false,
            close: function () { buscar(); }
        });

        cargarComentarios(tareaId);
    }

    function cargarComentarios(tareaId) {
        PageMethods.ObtenerComentarios(tareaId, function (lista) {
            var cont = $("#listaComentarios");
            cont.empty();

            if (!lista || lista.length === 0) {
                cont.html('<p class="text-muted" style="text-align:center;padding:1rem;">Sin comentarios aún.</p>');
                return;
            }

            $.each(lista, function (i, c) {
                cont.append(
                    '<div style="border-bottom:1px solid var(--border);padding:0.65rem 0;">' +
                    '<div style="display:flex;justify-content:space-between;margin-bottom:0.25rem;">' +
                    '<strong style="color:var(--accent);">' + c.Autor + '</strong>' +
                    '<span style="font-size:0.78rem;color:var(--text-muted);">' + c.FechaStr + ' &mdash; ' + c.RolAutor + '</span>' +
                    '</div>' +
                    '<p style="margin:0;color:var(--text);">' + c.Texto + '</p>' +
                    '</div>'
                );
            });
        });
    }

    function agregarComentario() {
        var texto = $.trim($("#txtComentario").val());
        if (!texto) { gtMostrarAlerta("error", "Escriba un comentario antes de agregar."); return; }

        PageMethods.InsertarComentario(_tareaIdComentario, texto,
            function (msg) {
                if (msg === "OK") {
                    $("#txtComentario").val("");
                    cargarComentarios(_tareaIdComentario);
                } else {
                    gtMostrarAlerta("error", msg);
                }
            },
            function () { gtMostrarAlerta("error", "Error al guardar el comentario."); }
        );
    }

    /* ── Cancelar tarea ── */
    function confirmarCancelar(id) {
        _tareaIdCancelar = id;
        $("#dlgCancelar").dialog({
            modal: true, width: 400, resizable: false,
            buttons: {
                "Sí, cancelar": function () {
                    $(this).dialog("close");
                    cancelarTarea(_tareaIdCancelar);
                },
                "Volver": function () { $(this).dialog("close"); }
            }
        });
    }

    function cancelarTarea(id) {
        PageMethods.Eliminar(id,
            function (msg) {
                gtMostrarAlerta("success", "&#10003; Tarea cancelada correctamente.");
                buscar();
            },
            function () { gtMostrarAlerta("error", "Error al cancelar la tarea."); }
        );
    }

    function obtenerQueryParam(name) {
        var r = new RegExp("[?&]" + name + "=([^&#]*)").exec(window.location.href);
        return r ? decodeURIComponent(r[1]) : null;
    }

    function cerrarSesion() {
        PageMethods.CerrarSesion(function () { window.location.href = "../Login.aspx"; });
    }
</script>

</body>
</html>
