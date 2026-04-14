<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FormProyecto.aspx.cs" Inherits="Gestion_Tareas.WebApp.Proyectos.FormProyecto" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>GestorTareas — Proyecto</title>

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

        <div class="flex-between mb-2">
            <h2 id="lblTitulo">Nuevo Proyecto</h2>
            <button type="button" class="gt-btn gt-btn-ghost"
                    onclick="window.location.href='ListaProyectos.aspx'">
                &#8592; Volver
            </button>
        </div>

        <div id="gt-alertas"></div>

        <div class="gt-card" style="max-width:680px;">

            <!-- Nombre -->
            <div class="gt-form-group">
                <label for="txtNombre">Nombre del Proyecto *</label>
                <input type="text" id="txtNombre" maxlength="150"
                       placeholder="Nombre descriptivo del proyecto"
                       title="Ingrese el nombre del proyecto (requerido)" />
            </div>

            <!-- Descripción -->
            <div class="gt-form-group">
                <label for="txtDesc">Descripción</label>
                <textarea id="txtDesc" maxlength="500" rows="3"
                          placeholder="Descripción detallada del proyecto..."
                          title="Descripción opcional del proyecto"></textarea>
            </div>

            <!-- Fechas -->
            <div class="gt-form-row">
                <div class="gt-form-group">
                    <label for="txtInicio">Fecha de Inicio *</label>
                    <input type="text" id="txtInicio" class="gt-date-free"
                           placeholder="dd/mm/aaaa" readonly="readonly"
                           title="Seleccione la fecha de inicio del proyecto" />
                </div>
                <div class="gt-form-group">
                    <label for="txtFin">Fecha de Fin</label>
                    <input type="text" id="txtFin" class="gt-date-free"
                           placeholder="dd/mm/aaaa (opcional)" readonly="readonly"
                           title="Fecha estimada de cierre del proyecto (opcional, debe ser mayor o igual a la de inicio)" />
                </div>
            </div>

            <!-- Estado -->
            <div class="gt-form-group" style="max-width:320px;">
                <label for="cmbEstado">Estado *</label>
                <select id="cmbEstado" title="Seleccione el estado actual del proyecto">
                    <option value="">— Seleccione —</option>
                </select>
            </div>

            <!-- Botones -->
            <div class="flex-between mt-3">
                <button type="button" class="gt-btn gt-btn-ghost"
                        onclick="window.location.href='ListaProyectos.aspx'">
                    Cancelar
                </button>
                <button type="button" id="btnGuardar" class="gt-btn gt-btn-primary"
                        onclick="guardar()">
                    &#10003; Guardar
                </button>
            </div>

        </div>
    </div>

</form>

<script src="https://code.jquery.com/jquery-1.12.4.min.js"></script>
<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
<script src="../Scripts/app.js"></script>

<script>
    var _proyectoId = 0;

    $(function () {
        PageMethods.ObtenerNombreSesion(function (n) { $("#lblUsuario").text(n); });

        PageMethods.ObtenerEstadosProyecto(function (lista) {
            $.each(lista, function (i, e) {
                $("#cmbEstado").append('<option value="' + e.Id + '">' + e.Descripcion + '</option>');
            });

            var id = obtenerQueryParam("id");
            if (id) {
                _proyectoId = parseInt(id);
                $("#lblTitulo").text("Editar Proyecto");
                cargarProyecto(_proyectoId);
            }
        });
    });

    function cargarProyecto(id) {
        PageMethods.ObtenerPorId(id, function (p) {
            if (!p) { gtMostrarAlerta("error", "Proyecto no encontrado."); return; }
            $("#txtNombre").val(p.Nombre);
            $("#txtDesc").val(p.Descripcion || "");
            $("#txtInicio").val(p.FechaInicioStr);
            if (p.FechaFinStr) $("#txtFin").val(p.FechaFinStr);
            $("#cmbEstado").val(p.EstadoProyectoId);
        });
    }

    function guardar() {
        if (!$.trim($("#txtNombre").val()))  { gtMostrarAlerta("error", "El nombre es requerido.");          return; }
        if (!$.trim($("#txtInicio").val()))  { gtMostrarAlerta("error", "La fecha de inicio es requerida."); return; }
        if (!$("#cmbEstado").val())          { gtMostrarAlerta("error", "Seleccione un estado.");            return; }

        gtBloquearBtn("#btnGuardar");

        PageMethods.Guardar(
            _proyectoId,
            $.trim($("#txtNombre").val()),
            $.trim($("#txtDesc").val()),
            $.trim($("#txtInicio").val()),
            $.trim($("#txtFin").val()),
            parseInt($("#cmbEstado").val()),
            function (msg) {
                if (msg === "OK") {
                    window.location.href = "ListaProyectos.aspx";
                } else {
                    gtMostrarAlerta("error", "&#10007; " + msg);
                    gtDesbloquearBtn("#btnGuardar");
                }
            },
            function () {
                gtMostrarAlerta("error", "Error de conexión al guardar.");
                gtDesbloquearBtn("#btnGuardar");
            }
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
