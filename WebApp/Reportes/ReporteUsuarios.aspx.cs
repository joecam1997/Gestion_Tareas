using Gestion_Tareas.Logica;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Reporting.WebForms;

namespace Gestion_Tareas.WebApp.Reports
{
    public partial class ReporteUsuarios : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Proteger página
            if (!SesionBLL.HaySesion(Request))
                Response.Redirect("~/WebApp/Login.aspx");

            if (!IsPostBack)
                CargarReporte();

        }

        private void CargarReporte()
        {
            // ── Leer filtros desde QueryString ──────────────────
            string nombre = Request.QueryString["nombre"] ?? string.Empty;
            string apellido = Request.QueryString["apellido"] ?? string.Empty;
            string cedula = Request.QueryString["cedula"] ?? string.Empty;
            string rolIdStr = Request.QueryString["rolId"] ?? string.Empty;

            int? rolId = null;
            if (!string.IsNullOrEmpty(rolIdStr) && int.TryParse(rolIdStr, out int rId))
                rolId = rId;

            // ── Mostrar resumen de filtros activos ──────────────
            var filtrosActivos = new List<string>();
            if (!string.IsNullOrEmpty(nombre)) filtrosActivos.Add("Nombre: " + nombre);
            if (!string.IsNullOrEmpty(apellido)) filtrosActivos.Add("Apellido: " + apellido);
            if (!string.IsNullOrEmpty(cedula)) filtrosActivos.Add("Cédula: " + cedula);
            if (rolId.HasValue) filtrosActivos.Add("RolId: " + rolId.Value);

            if (filtrosActivos.Count > 0)
            {
                pnlFiltros.Visible = true;
                lblFiltros.InnerText = "Filtros activos: " + string.Join(" | ", filtrosActivos);
            }

            // ── Obtener datos desde BLL ─────────────────────────
            var bll = new UsuarioBLL();
            var data = bll.ObtenerReporte(
                string.IsNullOrEmpty(nombre) ? null : nombre,
                string.IsNullOrEmpty(apellido) ? null : apellido,
                string.IsNullOrEmpty(cedula) ? null : cedula,
                rolId
            );

            // ── Configurar ReportViewer ─────────────────────────
            rvUsuarios.LocalReport.ReportPath = Server.MapPath("~/WebApp/Reportes/ReporteUsuarios.rdlc");
            rvUsuarios.LocalReport.DataSources.Clear();
            rvUsuarios.LocalReport.DataSources.Add(
                new ReportDataSource("dsUsuarios", data)
            );
            rvUsuarios.LocalReport.Refresh();
        }
    }
}