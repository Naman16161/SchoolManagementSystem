package servlet;

import util.DBConnection;
import java.io.IOException;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class TeacherLoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try {
            Connection conn = DBConnection.getConnection();  
            String sql = "SELECT * FROM teachers WHERE username=? AND password=?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, username);
            stmt.setString(2, password);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                HttpSession session = request.getSession();
                session.setAttribute("teacherId", rs.getInt("id"));
                session.setAttribute("teacherName", rs.getString("name"));
                session.setAttribute("teacherEmail", rs.getString("email"));
                session.setAttribute("teacherPhoto", rs.getString("photo"));
                response.sendRedirect("teacher_dashboard.jsp");
            } else {
                request.setAttribute("error", "Invalid username or password");
                RequestDispatcher rd = request.getRequestDispatcher("teacher_login.jsp");
                rd.forward(request, response);
            }
            conn.close(); 
        } catch (SQLException | ClassNotFoundException e) { 
            throw new ServletException(e);
        }
    }
}

