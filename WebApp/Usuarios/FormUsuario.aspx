<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FormUsuario.aspx.cs" Inherits="Gestion_Tareas.WebApp.Usuarios.FormUsuario" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>GestorTareas — Usuario</title>

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
            <h2 id="lblTitulo">Nuevo Usuario</h2>
            <button type="button" class="gt-btn gt-btn-ghost" onclick="window.location.href='ListaUsuarios.aspx'">
                &#8592; Volver
            </button>
        </div>

        <!-- Alertas -->
        <div id="gt-alertas"></div>

        <!-- Formulario -->
        <div class="gt-card" style="max-width:780px;">

            <!-- Fila 1: Nombre y Apellido -->
            <div class="gt-form-row">
                <div class="gt-form-group">
                    <label for="txtNombre">Nombre *</label>
                    <input type="text" id="txtNombre" maxlength="100"
                           placeholder="Nombre del usuario"
                           title="Ingrese el nombre del usuario (requerido)" />
                </div>
                <div class="gt-form-group">
                    <label for="txtApellido">Apellido *</label>
                    <input type="text" id="txtApellido" maxlength="100"
                           placeholder="Apellido del usuario"
                           title="Ingrese el apellido del usuario (requerido)" />
                </div>
            </div>

            <!-- Fila 2: Cédula y Fecha de Nacimiento -->
            <div class="gt-form-row">
                <div class="gt-form-group">
                    <label for="txtCedula">Cédula *</label>
                    <input type="text" id="txtCedula" maxlength="20"
                           placeholder="Número de cédula"
                           title="Ingrese el número de cédula o documento único del usuario" />
                </div>
                <div class="gt-form-group">
                    <label for="txtFechaNac">Fecha de Nacimiento *</label>
                    <input type="text" id="txtFechaNac" class="gt-date"
                           placeholder="dd/mm/aaaa" readonly="readonly"
                           title="Seleccione la fecha de nacimiento (use el calendario)" />
                </div>
            </div>

            <!-- Fila 3: Género y Estado Civil -->
            <div class="gt-form-row">
                <div class="gt-form-group">
                    <label for="cmbGenero">Género *</label>
                    <select id="cmbGenero" title="Seleccione el género del usuario">
                        <option value="">— Seleccione —</option>
                    </select>
                </div>
                <div class="gt-form-group">
                    <label for="cmbEstadoCivil">Estado Civil *</label>
                    <select id="cmbEstadoCivil" title="Seleccione el estado civil del usuario">
                        <option value="">— Seleccione —</option>
                    </select>
                </div>
            </div>

            <!-- Fila 4: Rol -->
            <div class="gt-form-row">
                <div class="gt-form-group">
                    <label for="cmbRol">Rol *</label>
                    <select id="cmbRol" title="Seleccione el rol que tendrá el usuario en el sistema">
                        <option value="">— Seleccione —</option>
                    </select>
                </div>
                <div class="gt-form-group">
                    <%-- Espacio reservado para alinear la grilla --%>
                </div>
            </div>

            <!-- Separador credenciales -->
            <div class="gt-card-title mt-2">Credenciales de Acceso</div>

            <!-- Fila 5: Login -->
            <div class="gt-form-row">
                <div class="gt-form-group">
                    <label for="txtLogin">Usuario de Login *</label>
                    <input type="text" id="txtLogin" maxlength="50"
                           placeholder="Nombre de usuario para ingresar"
                           title="Ingrese un nombre de usuario único para el acceso al sistema" />
                </div>
                <div class="gt-form-group" id="grpPass">
                    <label for="txtPass">Contraseña *</label>
                    <input type="password" id="txtPass" maxlength="100"
                           placeholder="Mínimo 8 chars, mayús, núm y especial"
                           title="La contraseña debe tener mínimo 8 caracteres, una mayúscula, un número y un carácter especial" />
                </div>
            </div>

            <!-- Nota contraseña en edición -->
            <p id="notaPass" class="text-muted mt-1" style="font-size:0.82rem; display:none;">
                &#9432; Deje la contraseña en blanco para no modificarla.
            </p>

            <!-- Botones -->
            <div class="flex-between mt-3">
                <button type="button" class="gt-btn gt-btn-ghost" onclick="window.location.href='ListaUsuarios.aspx'">
                    Cancelar
                </button>
                <button type="button" id="btnGuardar" class="gt-btn gt-btn-primary" onclick="guardar()">
                    &#10003; Guardar
                </button>
            </div>

        </div><!-- /gt-card -->

    </div><!-- /gt-main -->

</form>

<script src="https://code.jquery.com/jquery-1.12.4.min.js"></script>
<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
<script src="../Scripts/app.js"></script>

<script>
    var _usuarioId = 0; // 0 = alta, >0 = edición

    $(function () {
        // Nombre sesión en navbar
        PageMethods.ObtenerNombreSesion(function (n) { $("#lblUsuario").text(n); });

        // Cargar catálogos
        PageMethods.ObtenerCatalogos(function (cat) {
            cargarCombo("#cmbGenero",      cat.Generos,       "Id", "Descripcion");
            cargarCombo("#cmbEstadoCivil", cat.EstadosCiviles, "Id", "Descripcion");
            cargarCombo("#cmbRol",         cat.Roles,          "Id", "Descripcion");

            // Si viene ?id= en la URL, cargar datos para edición
            var id = obtenerQueryParam("id");
            if (id) {
                _usuarioId = parseInt(id);
                $("#lblTitulo").text("Editar Usuario");
                $("#notaPass").show();
                cargarUsuario(_usuarioId);
            }
        });
    });

    /* ── Helper: llenar combo ── */
    function cargarCombo(sel, lista, valField, txtField) {
        $.each(lista, function (i, item) {
            $(sel).append('<option value="' + item[valField] + '">' + item[txtField] + '</option>');
        });
    }

    /* ── Cargar datos del usuario en modo edición ── */
    function cargarUsuario(id) {
        PageMethods.ObtenerPorId(id, function (u) {
            if (!u) { gtMostrarAlerta("error", "Usuario no encontrado."); return; }

            $("#txtNombre").val(u.Nombre);
            $("#txtApellido").val(u.Apellido);
            $("#txtCedula").val(u.Cedula);
            $("#txtLogin").val(u.LoginUsuario);

            // Fecha de nacimiento: viene como DateTime, formatear dd/mm/yyyy
            if (u.FechaNacimiento) {
                var d = new Date(parseInt(u.FechaNacimiento.replace("/Date(", "").replace(")/", "")));
                var dia = ("0" + d.getDate()).slice(-2);
                var mes = ("0" + (d.getMonth() + 1)).slice(-2);
                $("#txtFechaNac").val(dia + "/" + mes + "/" + d.getFullYear());
            }

            $("#cmbGenero").val(u.GeneroId);
            $("#cmbEstadoCivil").val(u.EstadoCivilId);
            $("#cmbRol").val(u.RolId);
        });
    }

    /* ── Guardar (Alta o Edición) ── */
    function guardar() {
        // Validación client-side
        if (!$.trim($("#txtNombre").val()))      { gtMostrarAlerta("error", "El nombre es requerido.");            return; }
        if (!$.trim($("#txtApellido").val()))    { gtMostrarAlerta("error", "El apellido es requerido.");          return; }
        if (!$.trim($("#txtCedula").val()))      { gtMostrarAlerta("error", "La cédula es requerida.");            return; }
        if (!$.trim($("#txtFechaNac").val()))    { gtMostrarAlerta("error", "La fecha de nacimiento es requerida."); return; }
        if (!$("#cmbGenero").val())              { gtMostrarAlerta("error", "Seleccione un género.");              return; }
        if (!$("#cmbEstadoCivil").val())         { gtMostrarAlerta("error", "Seleccione el estado civil.");        return; }
        if (!$("#cmbRol").val())                 { gtMostrarAlerta("error", "Seleccione un rol.");                 return; }
        if (!$.trim($("#txtLogin").val()))       { gtMostrarAlerta("error", "El usuario de login es requerido."); return; }
        if (_usuarioId === 0 && !$.trim($("#txtPass").val())) {
            gtMostrarAlerta("error", "La contraseña es requerida para usuarios nuevos.");
            return;
        }

        gtBloquearBtn("#btnGuardar");

        var datos = {
            usuarioId:     _usuarioId,
            nombre:        $.trim($("#txtNombre").val()),
            apellido:      $.trim($("#txtApellido").val()),
            cedula:        $.trim($("#txtCedula").val()),
            fechaNac:      $.trim($("#txtFechaNac").val()),
            generoId:      parseInt($("#cmbGenero").val()),
            estadoCivilId: parseInt($("#cmbEstadoCivil").val()),
            rolId:         parseInt($("#cmbRol").val()),
            loginUsuario:  $.trim($("#txtLogin").val()),
            contrasena:    $.trim($("#txtPass").val())
        };

        PageMethods.Guardar(
            datos.usuarioId, datos.nombre, datos.apellido, datos.cedula,
            datos.fechaNac, datos.generoId, datos.estadoCivilId, datos.rolId,
            datos.loginUsuario, datos.contrasena,
            function (resultado) {
                if (resultado === "OK") {
                    window.location.href = "ListaUsuarios.aspx?msg=ok";
                } else {
                    gtMostrarAlerta("error", "&#10007; " + resultado);
                    gtDesbloquearBtn("#btnGuardar");
                }
            },
            function () {
                gtMostrarAlerta("error", "Error de conexión al guardar.");
                gtDesbloquearBtn("#btnGuardar");
            }
        );
    }

    /* ── Helpers ── */
    function obtenerQueryParam(name) {
        var results = new RegExp("[?&]" + name + "=([^&#]*)").exec(window.location.href);
        return results ? decodeURIComponent(results[1]) : null;
    }

    function cerrarSesion() {
        PageMethods.CerrarSesion(function () { window.location.href = "../Login.aspx"; });
    }
</script>

</body>
</html>
