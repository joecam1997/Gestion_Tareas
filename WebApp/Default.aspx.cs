using Gestion_Tareas.Logica;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Gestion_Tareas.WebApp
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (SesionBLL.HaySesion(Request))
                Response.Redirect("~/WebApp/Proyectos/ListaProyectos.aspx");
            else
                Response.Redirect("~/WebApp/Login.aspx");

        }
    }
}