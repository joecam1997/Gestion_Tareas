<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FormTarea.aspx.cs" Inherits="Gestion_Tareas.WebApp.Tareas.FormTarea" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>GestorTareas — Tarea</title>

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
            <h2 id="lblTitulo">Nueva Tarea</h2>
            <button type="button" class="gt-btn gt-btn-ghost"
                    onclick="window.location.href='ListaTareas.aspx'">
                &#8592; Volver
            </button>
        </div>

        <div id="gt-alertas"></div>

        <!-- ── Sección superior: datos de la tarea ── -->
        <div class="gt-card mb-2" style="max-width:780px;">

            <div class="gt-card-title">Datos de la Tarea</div>

            <!-- Proyecto y Título -->
            <div class="gt-form-row">
                <div class="gt-form-group">
                    <label for="cmbProyecto">Proyecto *</label>
                    <select id="cmbProyecto" title="Seleccione el proyecto al que pertenece esta tarea">
                        <option value="">— Seleccione —</option>
                    </select>
                </div>
                <div class="gt-form-group">
                    <label for="txtTitulo">Título *</label>
                    <input type="text" id="txtTitulo" maxlength="200"
                           placeholder="Título descriptivo de la tarea"
                           title="Ingrese el título de la tarea (requerido)" />
                </div>
            </div>

            <!-- Descripción -->
            <div class="gt-form-group">
                <label for="txtDesc">Descripción</label>
                <textarea id="txtDesc" maxlength="1000" rows="3"
                          placeholder="Detalle de la tarea..."
                          title="Descripción detallada de lo que se debe realizar"></textarea>
            </div>

            <!-- Asignado, Estado y Fecha Límite -->
            <div class="gt-form-row">
                <div class="gt-form-group">
                    <label for="cmbAsignado">Asignado a</label>
                    <select id="cmbAsignado" title="Seleccione el usuario responsable (puede dejarse sin asignar)">
                        <option value="">— Sin asignar —</option>
                    </select>
                </div>
                <div class="gt-form-group">
                    <label for="cmbEstado">Estado *</label>
                    <select id="cmbEstado" title="Seleccione el estado actual de la tarea">
                        <option value="">— Seleccione —</option>
                    </select>
                </div>
                <div class="gt-form-group">
                    <label for="txtFechaLimite">Fecha Límite</label>
                    <input type="text" id="txtFechaLimite" class="gt-date-free"
                           placeholder="dd/mm/aaaa (opcional)" readonly="readonly"
                           title="Fecha límite de entrega de la tarea (opcional)" />
                </div>
            </div>

            <!-- Botones guardar -->
            <div class="flex-between mt-3">
                <button type="button" class="gt-btn gt-btn-ghost"
                        onclick="window.location.href='ListaTareas.aspx'">
                    Cancelar
                </button>
                <button type="button" id="btnGuardar" class="gt-btn gt-btn-primary"
                        onclick="guardar()">
                    &#10003; Guardar Tarea
                </button>
            </div>

        </div>

        <!-- ── Sección inferior: comentarios (solo en modo edición) ── -->
        <div id="seccionComentarios" class="gt-card" style="max-width:780px;display:none;">

            <div class="gt-card-title">Comentarios</div>

            <!-- Lista de comentarios -->
            <div id="listaComentarios" style="margin-bottom:1.25rem;">
                <p class="text-muted" style="text-align:center;padding:1rem;">Sin comentarios aún.</p>
            </div>

            <!-- Agregar comentario -->
            <div style="border-top:1px solid var(--border);padding-top:1rem;">
                <div class="gt-form-group">
                    <label for="txtComentario">Agregar Comentario</label>
                    <textarea id="txtComentario" rows="3"
                              placeholder="Escriba su comentario..."
                              title="Escriba el comentario que desea agregar a esta tarea"></textarea>
                </div>
                <div style="text-align:right;">
                    <button type="button" class="gt-btn gt-btn-success" onclick="agregarComentario()">
                        &#10003; Agregar Comentario
                    </button>
                </div>
            </div>

        </div>

    </div>

</form>

<script src="https://code.jquery.com/jquery-1.12.4.min.js"></script>
<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
<script src="../Scripts/app.js"></script>

<script>
    var _tareaId = 0;

    $(function () {
        PageMethods.ObtenerNombreSesion(function (n) { $("#lblUsuario").text(n); });

        PageMethods.ObtenerCatalogos(function (cat) {
            // Llenar combos
            $.each(cat.Proyectos, function (i, p) {
                $("#cmbProyecto").append('<option value="' + p.Id + '">' + p.Descripcion + '</option>');
            });
            $.each(cat.Usuarios, function (i, u) {
                $("#cmbAsignado").append('<option value="' + u.Id + '">' + u.Descripcion + '</option>');
            });
            $.each(cat.EstadosTarea, function (i, e) {
                $("#cmbEstado").append('<option value="' + e.Id + '">' + e.Descripcion + '</option>');
            });

            // Modo edición
            var id = obtenerQueryParam("id");
            if (id) {
                _tareaId = parseInt(id);
                $("#lblTitulo").text("Editar Tarea");
                cargarTarea(_tareaId);
                cargarComentarios(_tareaId);
                $("#seccionComentarios").show();
            } else {
                // Pre-seleccionar proyecto si viene por querystring
                var qProy = obtenerQueryParam("proyectoId");
                if (qProy) $("#cmbProyecto").val(qProy);
            }
        });
    });

    function cargarTarea(id) {
        PageMethods.ObtenerPorId(id, function (t) {
            if (!t) { gtMostrarAlerta("error", "Tarea no encontrada."); return; }
            $("#cmbProyecto").val(t.ProyectoId);
            $("#txtTitulo").val(t.Titulo);
            $("#txtDesc").val(t.Descripcion || "");
            $("#cmbAsignado").val(t.AsignadoA || "");
            $("#cmbEstado").val(t.EstadoTareaId);
            if (t.FechaLimiteStr) $("#txtFechaLimite").val(t.FechaLimiteStr);
        });
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
                    '<div style="border-bottom:1px solid var(--border);padding:0.75rem 0;">' +
                    '<div style="display:flex;justify-content:space-between;margin-bottom:0.3rem;">' +
                    '<strong style="color:var(--accent);">' + c.Autor + '</strong>' +
                    '<span style="font-size:0.78rem;color:var(--text-muted);">' + c.FechaStr + ' &mdash; ' + c.RolAutor + '</span>' +
                    '</div>' +
                    '<p style="margin:0;">' + c.Texto + '</p>' +
                    '</div>'
                );
            });
        });
    }

    function agregarComentario() {
        var texto = $.trim($("#txtComentario").val());
        if (!texto) { gtMostrarAlerta("error", "Escriba un comentario antes de agregar."); return; }

        PageMethods.InsertarComentario(_tareaId, texto,
            function (msg) {
                if (msg === "OK") {
                    $("#txtComentario").val("");
                    cargarComentarios(_tareaId);
                    gtMostrarAlerta("success", "&#10003; Comentario agregado.");
                } else {
                    gtMostrarAlerta("error", msg);
                }
            },
            function () { gtMostrarAlerta("error", "Error al guardar el comentario."); }
        );
    }

    function guardar() {
        if (!$("#cmbProyecto").val())        { gtMostrarAlerta("error", "Seleccione un proyecto.");    return; }
        if (!$.trim($("#txtTitulo").val()))  { gtMostrarAlerta("error", "El título es requerido.");    return; }
        if (!$("#cmbEstado").val())          { gtMostrarAlerta("error", "Seleccione un estado.");      return; }

        gtBloquearBtn("#btnGuardar");

        PageMethods.Guardar(
            _tareaId,
            parseInt($("#cmbProyecto").val()),
            $.trim($("#txtTitulo").val()),
            $.trim($("#txtDesc").val()),
            $("#cmbAsignado").val() ? parseInt($("#cmbAsignado").val()) : null,
            parseInt($("#cmbEstado").val()),
            $.trim($("#txtFechaLimite").val()),
            function (msg) {
                if (msg === "OK") {
                    window.location.href = "ListaTareas.aspx";
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
