<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ListaUsuarios.aspx.cs" Inherits="Gestion_Tareas.WebApp.Usuarios.ListaUsuarios" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>GestorTareas — Usuarios</title>

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
            <a href="../Proyectos/ListaProyectos.aspx">Proyectos</a>
            <a href="../Tareas/ListaTareas.aspx">Tareas</a>
            <a href="ListaUsuarios.aspx" class="active">Usuarios</a>
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
            <h2>Gestión de Usuarios</h2>
            <div style="display:flex; gap:0.5rem;">
                <button type="button" class="gt-btn gt-btn-ghost" onclick="abrirReporte()">
                    &#128438; Reporte
                </button>
                <button type="button" class="gt-btn gt-btn-primary" onclick="window.location.href='FormUsuario.aspx'">
                    &#43; Nuevo Usuario
                </button>
            </div>
        </div>

        <!-- Alertas -->
        <div id="gt-alertas"></div>

        <!-- Filtros -->
        <div class="gt-filters">
            <div class="gt-form-group">
                <label for="fNombre">Nombre</label>
                <input type="text" id="fNombre" placeholder="Buscar por nombre..." title="Filtra por nombre del usuario" />
            </div>
            <div class="gt-form-group">
                <label for="fApellido">Apellido</label>
                <input type="text" id="fApellido" placeholder="Buscar por apellido..." title="Filtra por apellido del usuario" />
            </div>
            <div class="gt-form-group">
                <label for="fCedula">Cédula</label>
                <input type="text" id="fCedula" placeholder="Buscar por cédula..." title="Filtra por número de cédula" />
            </div>
            <div class="gt-form-group">
                <label for="fRol">Rol</label>
                <select id="fRol" title="Filtra por rol del usuario">
                    <option value="">— Todos —</option>
                </select>
            </div>
            <div class="gt-form-group">
                <label for="fActivo">Estado</label>
                <select id="fActivo" title="Filtra por estado activo o inactivo">
                    <option value="">— Todos —</option>
                    <option value="true">Activo</option>
                    <option value="false">Inactivo</option>
                </select>
            </div>
            <div class="gt-form-group" style="min-width:auto;">
                <label>&nbsp;</label>
                <button type="button" class="gt-btn gt-btn-primary" onclick="buscar()">Buscar</button>
            </div>
            <div class="gt-form-group" style="min-width:auto;">
                <label>&nbsp;</label>
                <button type="button" class="gt-btn gt-btn-ghost" onclick="limpiarFiltros()">Limpiar</button>
            </div>
        </div>

        <!-- Tabla -->
        <div class="gt-card">
            <div class="gt-table-wrap">
                <table class="gt-table">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Nombre completo</th>
                            <th>Cédula</th>
                            <th>Género</th>
                            <th>Estado Civil</th>
                            <th>Rol</th>
                            <th>Login</th>
                            <th>Estado</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody id="tblBody">
                        <tr>
                            <td colspan="9" style="text-align:center; color:var(--text-muted); padding:2rem;">
                                Cargando usuarios...
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

    </div><!-- /gt-main -->

    <!-- Diálogo de confirmación de eliminación (oculto) -->
    <div id="dlgEliminar" title="Confirmar eliminación" style="display:none;">
        <p>¿Está seguro de que desea desactivar este usuario? Esta acción aplica eliminación lógica.</p>
    </div>

</form>

<script src="https://code.jquery.com/jquery-1.12.4.min.js"></script>
<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
<script src="../Scripts/app.js"></script>

<script>
    var _idEliminar = 0;

    $(function () {
        cargarRoles();
        buscar();
        // Mostrar nombre de sesión
        PageMethods.ObtenerNombreSesion(function (n) { $("#lblUsuario").text(n); });
    });

    /* ── Cargar combo de roles ── */
    function cargarRoles() {
        PageMethods.ObtenerRoles(function (lista) {
            $.each(lista, function (i, r) {
                $("#fRol").append('<option value="' + r.Id + '">' + r.Descripcion + '</option>');
            });
        });
    }

    /* ── Buscar / listar usuarios ── */
    function buscar() {
        var filtros = {
            nombre:   $.trim($("#fNombre").val())   || null,
            apellido: $.trim($("#fApellido").val()) || null,
            cedula:   $.trim($("#fCedula").val())   || null,
            rolId:    $("#fRol").val()   ? parseInt($("#fRol").val())   : null,
            activo:   $("#fActivo").val() !== "" ? ($("#fActivo").val() === "true") : null
        };

        PageMethods.Consultar(
            filtros.nombre, filtros.apellido, filtros.cedula, filtros.rolId, filtros.activo,
            function (lista) {
                var tbody = $("#tblBody");
                tbody.empty();

                if (!lista || lista.length === 0) {
                    tbody.append('<tr><td colspan="9" style="text-align:center;color:var(--text-muted);padding:2rem;">No se encontraron usuarios.</td></tr>');
                    return;
                }

                $.each(lista, function (i, u) {
                    var estado = u.Activo ? gtBadge("Activo") : gtBadge("Inactivo");
                    var acciones =
                        '<div class="actions">' +
                        '<button type="button" class="gt-btn gt-btn-ghost gt-btn-sm" ' +
                        'onclick="editar(' + u.UsuarioId + ')" title="Editar usuario">&#9998; Editar</button>' +
                        (u.Activo
                            ? '<button type="button" class="gt-btn gt-btn-danger gt-btn-sm" ' +
                              'onclick="confirmarEliminar(' + u.UsuarioId + ')" title="Desactivar usuario">&#128683; Desactivar</button>'
                            : '') +
                        '</div>';

                    tbody.append(
                        '<tr>' +
                        '<td>' + (i + 1) + '</td>' +
                        '<td>' + u.Nombre + ' ' + u.Apellido + '</td>' +
                        '<td>' + u.Cedula + '</td>' +
                        '<td>' + (u.GeneroNombre || '—') + '</td>' +
                        '<td>' + (u.EstadoCivilNombre || '—') + '</td>' +
                        '<td>' + (u.RolNombre || '—') + '</td>' +
                        '<td><span style="color:var(--text-muted)">' + u.LoginUsuario + '</span></td>' +
                        '<td>' + estado + '</td>' +
                        '<td>' + acciones + '</td>' +
                        '</tr>'
                    );
                });
            },
            function () { gtMostrarAlerta("error", "Error al cargar usuarios."); }
        );
    }

    /* ── Limpiar filtros ── */
    function limpiarFiltros() {
        $("#fNombre, #fApellido, #fCedula").val("");
        $("#fRol, #fActivo").val("");
        buscar();
    }

    /* ── Editar usuario ── */
    function editar(id) {
        window.location.href = "FormUsuario.aspx?id=" + id;
    }

    /* ── Confirmar eliminación con jQuery UI Dialog ── */
    function confirmarEliminar(id) {
        _idEliminar = id;
        $("#dlgEliminar").dialog({
            modal:     true,
            width:     400,
            resizable: false,
            buttons: {
                "Sí, desactivar": function () {
                    $(this).dialog("close");
                    eliminar(_idEliminar);
                },
                "Cancelar": function () { $(this).dialog("close"); }
            }
        });
    }

    /* ── Eliminar (lógico) ── */
    function eliminar(id) {
        PageMethods.Eliminar(id,
            function (msg) {
                gtMostrarAlerta("success", "&#10003; " + msg);
                buscar();
            },
            function () { gtMostrarAlerta("error", "Error al desactivar el usuario."); }
        );
    }

    /* ── Abrir reporte con filtros activos ── */
    function abrirReporte() {
        var qs = "?nombre="   + encodeURIComponent($("#fNombre").val())
               + "&apellido=" + encodeURIComponent($("#fApellido").val())
               + "&cedula="   + encodeURIComponent($("#fCedula").val())
               + "&rolId="    + encodeURIComponent($("#fRol").val());
        window.open("../Reportes/ReporteUsuarios.aspx" + qs, "_blank");
    }

    /* ── Cerrar sesión ── */
    function cerrarSesion() {
        PageMethods.CerrarSesion(function () {
            window.location.href = "../Login.aspx";
        });
    }
</script>

</body>
</html>
