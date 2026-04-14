<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReporteUsuarios.aspx.cs" Inherits="Gestion_Tareas.WebApp.Reports.ReporteUsuarios" %>
<%@ Register Assembly="Microsoft.ReportViewer.WebForms"
Namespace="Microsoft.Reporting.WebForms"
TagPrefix="rsweb" %>    Namespace="Microsoft.Reporting.WebForms" TagPrefix="rsweb" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>GestorTareas — Reporte de Usuarios</title>

    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;600;700&family=Source+Sans+3:wght@300;400;600&display=swap" rel="stylesheet" />
    <link href="../Styles/site.css" rel="stylesheet" />

    <style>
        /* Forzar fondo claro solo en la zona del ReportViewer */
        .rv-wrap {
            background: #fff;
            border-radius: 6px;
            overflow: hidden;
            border: 1px solid var(--border);
        }

        /* Barra de herramientas del ReportViewer */
        .MicrosoftReportViewer table { font-family: 'Source Sans 3', sans-serif !important; }
    </style>
</head>
<body>
<form id="form1" runat="server">

    <asp:ScriptManager ID="ScriptManager1" runat="server" />

    <!-- ── Navbar ── -->
    <nav class="gt-navbar">
        <span class="brand">Gestor<span>Tareas</span></span>
        <div class="nav-links">
            <a href="../Proyectos/ListaProyectos.aspx">Proyectos</a>
            <a href="../Tareas/ListaTareas.aspx">Tareas</a>
            <a href="../Usuarios/ListaUsuarios.aspx" class="active">Usuarios</a>
        </div>
        <div class="nav-user">
            <a href="../Usuarios/ListaUsuarios.aspx" class="gt-btn gt-btn-ghost gt-btn-sm">
                &#8592; Volver a Usuarios
            </a>
        </div>
    </nav>

    <div class="gt-main">

        <div class="flex-between mb-2">
            <h2>Reporte de Usuarios</h2>
            <span class="text-muted" style="font-size:0.85rem;">
                Filtros aplicados desde la lista de usuarios
            </span>
        </div>

        <!-- Resumen de filtros activos -->
        <div id="pnlFiltros" runat="server" class="gt-alert gt-alert-info mb-2" visible="false">
            <span id="lblFiltros" runat="server"></span>
        </div>

        <!-- ReportViewer -->
        <div class="rv-wrap">
            <rsweb:ReportViewer ID="rvUsuarios" runat="server"
                Width="100%"
                Height="600px"
                ProcessingMode="Local"
                ShowBackButton="False"
                ShowFindControls="True"
                ShowPageNavigationControls="True"
                ShowPrintButton="True"
                ShowExportControls="True"
                ShowRefreshButton="False"
                SizeToReportContent="False"
                ZoomMode="PageWidth">
            </rsweb:ReportViewer>
        </div>

    </div>

</form>

<script src="https://code.jquery.com/jquery-1.12.4.min.js"></script>
<script src="../Scripts/app.js"></script>
</body>
</html>
