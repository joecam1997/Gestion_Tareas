<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ListaProyectos.aspx.cs" Inherits="Gestion_Tareas.WebApp.Proyectos.ListaProyectos" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>GestorTareas — Proyectos</title>

    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;600;700&family=Source+Sans+3:wght@300;400;600&display=swap" rel="stylesheet" />
    <link href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.min.css" rel="stylesheet" />
    <link href="../Styles/site.css" rel="stylesheet" />
</head>
<body>
<form id="form1" runat="server">

    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" />

    <!-- ── Navbar ── -->
    <nav class="gt-navbar">
        <span class="brand">Gestor<span>Tareas</span></span>
        <div class="nav-links">
            <a href="ListaProyectos.aspx" class="active">Proyectos</a>
            <a href="../Tareas/ListaTareas.aspx">Tareas</a>
            <a href="../Usuarios/ListaUsuarios.aspx">Usuarios</a>
        </div>
        <div class="nav-user">
            Bienvenido, <strong><span id="lblUsuario"></span></strong>
            &nbsp;|&nbsp;
            <a href="#" onclick="cerrarSesion()">Salir</a>
        </div>
    </nav>

    <div class="gt-main">

        <!-- Encabezado -->
        <div class="flex-between mb-2">
            <h2>Gestión de Proyectos</h2>
            <button type="button" class="gt-btn gt-btn-primary"
                    onclick="window.location.href='FormProyecto.aspx'">
                &#43; Nuevo Proyecto
            </button>
        </div>

        <!-- Alertas -->
        <div id="gt-alertas"></div>

        <!-- Filtros -->
        <div class="gt-filters">
            <div class="gt-form-group">
                <label for="fNombre">Nombre del proyecto</label>
                <input type="text" id="fNombre" placeholder="Buscar proyecto..."
                       title="Filtra proyectos por nombre" />
            </div>
            <div class="gt-form-group">
                <label for="fEstado">Estado</label>
                <select id="fEstado" title="Filtra por estado del proyecto">
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
                            <th>Nombre</th>
                            <th>Descripción</th>
                            <th>Fecha Inicio</th>
                            <th>Fecha Fin</th>
                            <th>Estado</th>
                            <th>Creado por</th>
                            <th>Tareas</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody id="tblBody">
                        <tr>
                            <td colspan="9" style="text-align:center;color:var(--text-muted);padding:2rem;">
                                Cargando proyectos...
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

    </div>

    <!-- Diálogo confirmación suspensión -->
    <div id="dlgSuspender" title="Confirmar suspensión" style="display:none;">
        <p>¿Está seguro de que desea suspender este proyecto?</p>
        <p class="text-muted" style="font-size:0.85rem;margin-top:0.5rem;">
            No se puede suspender un proyecto con tareas <strong>En Progreso</strong>.
        </p>
    </div>

</form>

<script src="https://code.jquery.com/jquery-1.12.4.min.js"></script>
<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
<script src="../Scripts/app.js"></script>

<script>
    var _idSuspender = 0;

    $(function () {
        PageMethods.ObtenerNombreSesion(function (n) { $("#lblUsuario").text(n); });
        cargarEstados();
        buscar();
    });

    function cargarEstados() {
        PageMethods.ObtenerEstadosProyecto(function (lista) {
            $.each(lista, function (i, e) {
                $("#fEstado").append('<option value="' + e.Id + '">' + e.Descripcion + '</option>');
            });
        });
    }

    function buscar() {
        var nombre  = $.trim($("#fNombre").val()) || null;
        var estadoId = $("#fEstado").val() ? parseInt($("#fEstado").val()) : null;

        PageMethods.Consultar(nombre, estadoId,
            function (lista) {
                var tbody = $("#tblBody");
                tbody.empty();

                if (!lista || lista.length === 0) {
                    tbody.append('<tr><td colspan="9" style="text-align:center;color:var(--text-muted);padding:2rem;">No se encontraron proyectos.</td></tr>');
                    return;
                }

                $.each(lista, function (i, p) {
                    var fin = p.FechaFinStr || "—";
                    var tareas = '<span title="' + p.TareasCompletadas + ' completadas de ' + p.TotalTareas + '">'
                               + p.TareasCompletadas + ' / ' + p.TotalTareas + '</span>';

                    var acciones =
                        '<div class="actions">' +
                        '<button type="button" class="gt-btn gt-btn-ghost gt-btn-sm" ' +
                        'onclick="verTareas(' + p.ProyectoId + ')" title="Ver tareas de este proyecto">&#128196; Tareas</button>' +
                        '<button type="button" class="gt-btn gt-btn-ghost gt-btn-sm" ' +
                        'onclick="editar(' + p.ProyectoId + ')" title="Editar proyecto">&#9998; Editar</button>' +
                        '<button type="button" class="gt-btn gt-btn-danger gt-btn-sm" ' +
                        'onclick="confirmarSuspender(' + p.ProyectoId + ')" title="Suspender proyecto">&#9632; Suspender</button>' +
                        '</div>';

                    tbody.append(
                        '<tr>' +
                        '<td>' + (i + 1) + '</td>' +
                        '<td><strong>' + p.Nombre + '</strong></td>' +
                        '<td style="max-width:220px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" title="' + (p.Descripcion || '') + '">' + (p.Descripcion || '<span class="text-muted">—</span>') + '</td>' +
                        '<td>' + p.FechaInicioStr + '</td>' +
                        '<td>' + fin + '</td>' +
                        '<td>' + gtBadge(p.EstadoProyectoNombre) + '</td>' +
                        '<td>' + (p.CreadoPorNombre || '—') + '</td>' +
                        '<td>' + tareas + '</td>' +
                        '<td>' + acciones + '</td>' +
                        '</tr>'
                    );
                });
            },
            function () { gtMostrarAlerta("error", "Error al cargar proyectos."); }
        );
    }

    function limpiar() {
        $("#fNombre").val("");
        $("#fEstado").val("");
        buscar();
    }

    function editar(id) {
        window.location.href = "FormProyecto.aspx?id=" + id;
    }

    function verTareas(id) {
        window.location.href = "../Tareas/ListaTareas.aspx?proyectoId=" + id;
    }

    function confirmarSuspender(id) {
        _idSuspender = id;
        $("#dlgSuspender").dialog({
            modal: true, width: 420, resizable: false,
            buttons: {
                "Sí, suspender": function () {
                    $(this).dialog("close");
                    suspender(_idSuspender);
                },
                "Cancelar": function () { $(this).dialog("close"); }
            }
        });
    }

    function suspender(id) {
        PageMethods.Eliminar(id,
            function (msg) {
                if (msg === "OK") {
                    gtMostrarAlerta("success", "&#10003; Proyecto suspendido correctamente.");
                    buscar();
                } else {
                    gtMostrarAlerta("error", "&#10007; " + msg);
                }
            },
            function () { gtMostrarAlerta("error", "Error al suspender el proyecto."); }
        );
    }

    function cerrarSesion() {
        PageMethods.CerrarSesion(function () { window.location.href = "../Login.aspx"; });
    }
</script>

</body>
</html>
