package servlet;

import util.DBConnection;
import java.io.IOException;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class DeleteHomeworkServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        String className = request.getParameter("class");

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "DELETE FROM homework WHERE id=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            throw new ServletException(e);
        }
        // Redirect to the same class view
        response.sendRedirect("manage_homework.jsp?class=" + className);
    }
}
