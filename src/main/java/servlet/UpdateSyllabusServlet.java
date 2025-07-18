package servlet;

import util.DBConnection;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class UpdateSyllabusServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String className = request.getParameter("class");
        String subject = request.getParameter("subject");
        List<String> pts = Arrays.asList("PT1", "PT2", "PT3", "PT4");

        try (Connection conn = DBConnection.getConnection()) {
            for (String pt : pts) {
                String content = request.getParameter("syllabus_" + pt);
                // Check if record exists
                PreparedStatement check = conn.prepareStatement(
                    "SELECT id FROM syllabus WHERE class=? AND subject=? AND pt=?");
                check.setString(1, className);
                check.setString(2, subject);
                check.setString(3, pt);
                ResultSet rs = check.executeQuery();
                if (rs.next()) {
                    // Update
                    PreparedStatement update = conn.prepareStatement(
                        "UPDATE syllabus SET syllabus_content=? WHERE class=? AND subject=? AND pt=?");
                    update.setString(1, content);
                    update.setString(2, className);
                    update.setString(3, subject);
                    update.setString(4, pt);
                    update.executeUpdate();
                } else {
                    // Insert
                    PreparedStatement insert = conn.prepareStatement(
                        "INSERT INTO syllabus (class, subject, pt, syllabus_content) VALUES (?, ?, ?, ?)");
                    insert.setString(1, className);
                    insert.setString(2, subject);
                    insert.setString(3, pt);
                    insert.setString(4, content);
                    insert.executeUpdate();
                }
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
        response.sendRedirect("manage_syllabus.jsp?class=" + className + "&subject=" + subject);
    }
}
