using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace Gestion_Tareas.AccesoDatos
{
    public class Conexion
    {
        private string cadenaConexion =
            ConfigurationManager.ConnectionStrings["GestorTareas"].ConnectionString;

        public SqlConnection ObtenerConexion()
        {
            SqlConnection con = new SqlConnection(cadenaConexion);
            con.Open();
            return con;
        }
    }
}