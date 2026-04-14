using Gestion_Tareas.Objectos;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace Gestion_Tareas.AccesoDatos
{
    public class UsuarioDAL
    {
        private Conexion _conexion = new Conexion();

        // -------------------------------------------------------
        //  Insertar  →  sp_InsertarUsuario
        //  Retorna: >0 = nuevo ID,  -1 = cédula duplicada,  -2 = login duplicado
        // -------------------------------------------------------
        public int Insertar(UsuarioObj u)
        {
            using (var con = _conexion.ObtenerConexion())
            using (var cmd = new SqlCommand("sp_InsertarUsuario", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@Nombre", u.Nombre);
                cmd.Parameters.AddWithValue("@Apellido", u.Apellido);
                cmd.Parameters.AddWithValue("@Cedula", u.Cedula);
                cmd.Parameters.AddWithValue("@GeneroId", u.GeneroId);
                cmd.Parameters.AddWithValue("@FechaNacimiento", u.FechaNacimiento);
                cmd.Parameters.AddWithValue("@EstadoCivilId", u.EstadoCivilId);
                cmd.Parameters.AddWithValue("@RolId", u.RolId);
                cmd.Parameters.AddWithValue("@LoginUsuario", u.LoginUsuario);
                cmd.Parameters.AddWithValue("@Contrasena", u.Contrasena);

                using (var dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                        return Convert.ToInt32(dr["Resultado"]);
                }
            }

            return 0;
        }

        // -------------------------------------------------------
        //  Actualizar  →  sp_ActualizarUsuario
        //  Retorna: >0 = ID actualizado,  -1 = cédula duplicada en otro usuario
        // -------------------------------------------------------
        public int Actualizar(UsuarioObj u)
        {
            using (var con = _conexion.ObtenerConexion())
            using (var cmd = new SqlCommand("sp_ActualizarUsuario", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@UsuarioId", u.UsuarioId);
                cmd.Parameters.AddWithValue("@Nombre", u.Nombre);
                cmd.Parameters.AddWithValue("@Apellido", u.Apellido);
                cmd.Parameters.AddWithValue("@Cedula", u.Cedula);
                cmd.Parameters.AddWithValue("@GeneroId", u.GeneroId);
                cmd.Parameters.AddWithValue("@FechaNacimiento", u.FechaNacimiento);
                cmd.Parameters.AddWithValue("@EstadoCivilId", u.EstadoCivilId);
                cmd.Parameters.AddWithValue("@RolId", u.RolId);
                cmd.Parameters.AddWithValue("@LoginUsuario", u.LoginUsuario);

                using (var dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                        return Convert.ToInt32(dr["Resultado"]);
                }
            }

            return 0;
        }

        // -------------------------------------------------------
        //  Eliminar lógico  →  sp_EliminarUsuario  (Activo = 0)
        // -------------------------------------------------------
        public void Eliminar(int usuarioId)
        {
            using (var con = _conexion.ObtenerConexion())
            using (var cmd = new SqlCommand("sp_EliminarUsuario", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@UsuarioId", usuarioId);
                cmd.ExecuteNonQuery();
            }
        }

        // -------------------------------------------------------
        //  Consultar con filtros  →  sp_ConsultarUsuarios
        //  Cualquier filtro en null = sin filtro
        // -------------------------------------------------------
        public List<UsuarioObj> Consultar(string nombre = null, string apellido = null,
                                          string cedula = null, int? rolId = null,
                                          bool? activo = null)
        {
            var lista = new List<UsuarioObj>();

            using (var con = _conexion.ObtenerConexion())
            using (var cmd = new SqlCommand("sp_ConsultarUsuarios", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@Nombre", (object)nombre ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Apellido", (object)apellido ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Cedula", (object)cedula ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@RolId", rolId.HasValue ? (object)rolId.Value : DBNull.Value);
                cmd.Parameters.AddWithValue("@Activo", activo.HasValue ? (object)activo.Value : DBNull.Value);

                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        lista.Add(new UsuarioObj
                        {
                            UsuarioId = (int)dr["UsuarioId"],
                            Nombre = dr["Nombre"].ToString(),
                            Apellido = dr["Apellido"].ToString(),
                            Cedula = dr["Cedula"].ToString(),
                            GeneroNombre = dr["Genero"].ToString(),
                            FechaNacimiento = (DateTime)dr["FechaNacimiento"],
                            EstadoCivilNombre = dr["EstadoCivil"].ToString(),
                            RolNombre = dr["Rol"].ToString(),
                            LoginUsuario = dr["LoginUsuario"].ToString(),
                            Activo = (bool)dr["Activo"],
                            FechaCreacion = (DateTime)dr["FechaCreacion"]
                        });
                    }
                }
            }

            return lista;
        }

        // -------------------------------------------------------
        //  Obtener por ID  →  sp_ObtenerUsuarioPorId
        // -------------------------------------------------------
        public UsuarioObj ObtenerPorId(int usuarioId)
        {
            UsuarioObj usuario = null;

            using (var con = _conexion.ObtenerConexion())
            using (var cmd = new SqlCommand("sp_ObtenerUsuarioPorId", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@UsuarioId", usuarioId);

                using (var dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        usuario = new UsuarioObj
                        {
                            UsuarioId = (int)dr["UsuarioId"],
                            Nombre = dr["Nombre"].ToString(),
                            Apellido = dr["Apellido"].ToString(),
                            Cedula = dr["Cedula"].ToString(),
                            GeneroId = (int)dr["GeneroId"],
                            GeneroNombre = dr["Genero"].ToString(),
                            FechaNacimiento = (DateTime)dr["FechaNacimiento"],
                            EstadoCivilId = (int)dr["EstadoCivilId"],
                            EstadoCivilNombre = dr["EstadoCivil"].ToString(),
                            RolId = (int)dr["RolId"],
                            RolNombre = dr["Rol"].ToString(),
                            LoginUsuario = dr["LoginUsuario"].ToString(),
                            Activo = (bool)dr["Activo"]
                        };
                    }
                }
            }

            return usuario;
        }

        // -------------------------------------------------------
        //  Autenticar  →  sp_AutenticarUsuario
        //  Retorna el usuario si las credenciales son válidas, null si no
        // -------------------------------------------------------
        public UsuarioObj Autenticar(string loginUsuario, string contrasenaHash)
        {
            UsuarioObj usuario = null;

            using (var con = _conexion.ObtenerConexion())
            using (var cmd = new SqlCommand("sp_AutenticarUsuario", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@Contrasena", SqlDbType.VarChar, 64).Value = contrasenaHash;
                cmd.Parameters.Add("@LoginUsuario", SqlDbType.NVarChar, 50).Value = loginUsuario.Trim();

                using (var dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        usuario = new UsuarioObj
                        {
                            UsuarioId = (int)dr["UsuarioId"],
                            Nombre = dr["Nombre"].ToString(),
                            Apellido = dr["Apellido"].ToString(),
                            LoginUsuario = dr["LoginUsuario"].ToString(),
                            RolNombre = dr["Rol"].ToString()
                        };
                    }
                }
            }

            return usuario;
        }

        // -------------------------------------------------------
        //  Reporte  →  sp_ReporteUsuarios  (para ReportViewer)
        // -------------------------------------------------------
        public DataTable ObtenerReporte(string nombre = null, string apellido = null,
                                        string cedula = null, int? rolId = null)
        {
            var dt = new DataTable();

            using (var con = _conexion.ObtenerConexion())
            using (var cmd = new SqlCommand("sp_ReporteUsuarios", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@Nombre", (object)nombre ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Apellido", (object)apellido ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Cedula", (object)cedula ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@RolId", rolId.HasValue ? (object)rolId.Value : DBNull.Value);

                using (var da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }

            return dt;
        }
    }
}