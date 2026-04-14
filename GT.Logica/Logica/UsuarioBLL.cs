
using Gestion_Tareas.Objectos;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;

namespace Gestion_Tareas.Logica
{
    public class UsuarioBLL
    {
        private UsuarioDAL _dal = new UsuarioDAL();

        // -------------------------------------------------------
        //  Insertar usuario con validaciones de negocio
        //  Retorna: >0 = OK,  -1 = cédula duplicada,
        //           -2 = login duplicado,  -3 = contraseña débil,
        //           -4 = fecha nacimiento inválida
        // -------------------------------------------------------
        public int Insertar(UsuarioObj u, string contrasenaPlana)
        {
            // Validar complejidad de contraseña
            if (!ContrasenaValida(contrasenaPlana))
                return -3;

            // Validar fecha de nacimiento (mínimo 10 años, máximo 100)
            if (!FechaValida(u.FechaNacimiento))
                return -4;

            // Aplicar hash antes de enviar a la DAL
            u.Contrasena = SesionBLL.HashSHA256(contrasenaPlana);

            return _dal.Insertar(u);
        }

        // -------------------------------------------------------
        //  Actualizar usuario (sin cambiar contraseña)
        //  Retorna: >0 = OK,  -1 = cédula duplicada,
        //           -4 = fecha nacimiento inválida
        // -------------------------------------------------------
        public int Actualizar(UsuarioObj u)
        {
            if (!FechaValida(u.FechaNacimiento))
                return -4;

            return _dal.Actualizar(u);
        }

        // -------------------------------------------------------
        //  Eliminar lógico
        // -------------------------------------------------------
        public void Eliminar(int usuarioId)
        {
            _dal.Eliminar(usuarioId);
        }

        // -------------------------------------------------------
        //  Consultar con filtros opcionales
        // -------------------------------------------------------
        public List<UsuarioObj> Consultar(string nombre = null, string apellido = null,
                                          string cedula = null, int? rolId = null,
                                          bool? activo = null)
        {
            return _dal.Consultar(nombre, apellido, cedula, rolId, activo);
        }

        // -------------------------------------------------------
        //  Obtener por ID
        // -------------------------------------------------------
        public UsuarioObj ObtenerPorId(int usuarioId)
        {
            return _dal.ObtenerPorId(usuarioId);
        }

        // -------------------------------------------------------
        //  Reporte para ReportViewer
        // -------------------------------------------------------
        public System.Data.DataTable ObtenerReporte(string nombre = null, string apellido = null,
                                                    string cedula = null, int? rolId = null)
        {
            return _dal.ObtenerReporte(nombre, apellido, cedula, rolId);
        }

        // -------------------------------------------------------
        //  Helpers de validación privados
        // -------------------------------------------------------

        /// <summary>
        /// Contraseña válida: mínimo 8 caracteres, al menos 1 mayúscula,
        /// 1 minúscula, 1 número y 1 carácter especial.
        /// </summary>
        private bool ContrasenaValida(string contrasena)
        {
            if (string.IsNullOrEmpty(contrasena) || contrasena.Length < 8)
                return false;

            bool tieneMayus = Regex.IsMatch(contrasena, "[A-Z]");
            bool tieneMinus = Regex.IsMatch(contrasena, "[a-z]");
            bool tieneNumero = Regex.IsMatch(contrasena, "[0-9]");
            bool tieneEspecial = Regex.IsMatch(contrasena, "[^a-zA-Z0-9]");

            return tieneMayus && tieneMinus && tieneNumero && tieneEspecial;
        }

        /// <summary>
        /// Fecha de nacimiento: el usuario debe tener entre 10 y 100 años.
        /// </summary>
        private bool FechaValida(DateTime fecha)
        {
            int edad = DateTime.Today.Year - fecha.Year;
            if (fecha.Date > DateTime.Today.AddYears(-edad)) edad--;
            return edad >= 10 && edad <= 100;
        }
    }
}