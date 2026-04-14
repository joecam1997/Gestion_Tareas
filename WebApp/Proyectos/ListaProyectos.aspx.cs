using Gestion_Tareas.AccesoDatos;
using Gestion_Tareas.Logica;
using Gestion_Tareas.Objectos;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Gestion_Tareas.WebApp.Proyectos
{
    public partial class ListaProyectos : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SesionBLL.HaySesion(Request))
                Response.Redirect("~/WebApp/Login.aspx");

        }
        [WebMethod]
        public static string ObtenerNombreSesion()
        {
            return SesionBLL.ObtenerNombreCompleto(HttpContext.Current.Request);
        }

        [WebMethod]
        public static List<CatalogoObj> ObtenerEstadosProyecto()
        {
            return new CatalogoDAL().ObtenerEstadosProyecto();
        }

        [WebMethod]
        public static List<ProyectoDTO> Consultar(string nombre, int? estadoProyectoId)
        {
            var bll = new ProyectoBLL();
            var lista = bll.Consultar(
                string.IsNullOrEmpty(nombre) ? null : nombre,
                estadoProyectoId
            );

            // Convertimos a DTO para serializar fechas como string legible
            var resultado = new List<ProyectoDTO>();
            foreach (var p in lista)
            {
                resultado.Add(new ProyectoDTO
                {
                    ProyectoId = p.ProyectoId,
                    Nombre = p.Nombre,
                    Descripcion = p.Descripcion,
                    FechaInicioStr = p.FechaInicio.ToString("dd/MM/yyyy"),
                    FechaFinStr = p.FechaFin.HasValue ? p.FechaFin.Value.ToString("dd/MM/yyyy") : null,
                    EstadoProyectoNombre = p.EstadoProyectoNombre,
                    CreadoPorNombre = p.CreadoPorNombre,
                    TotalTareas = p.TotalTareas,
                    TareasCompletadas = p.TareasCompletadas
                });
            }
            return resultado;
        }

        [WebMethod]
        public static string Eliminar(int proyectoId)
        {
            int res = new ProyectoBLL().Eliminar(proyectoId);
            if (res == -2) return "El proyecto tiene tareas En Progreso. Finalícelas antes de suspenderlo.";
            return "OK";
        }

        [WebMethod]
        public static void CerrarSesion()
        {
            SesionBLL.CerrarSesion(HttpContext.Current.Response);
        }


        // DTO para serializar fechas como string hacia el cliente
        public class ProyectoDTO
        {
            public int ProyectoId { get; set; }
            public string Nombre { get; set; }
            public string Descripcion { get; set; }
            public string FechaInicioStr { get; set; }
            public string FechaFinStr { get; set; }
            public string EstadoProyectoNombre { get; set; }
            public string CreadoPorNombre { get; set; }
            public int TotalTareas { get; set; }
            public int TareasCompletadas { get; set; }
        }
    }
}