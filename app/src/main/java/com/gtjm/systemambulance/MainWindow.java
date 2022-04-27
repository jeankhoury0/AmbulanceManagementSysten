package com.gtjm.systemambulance;

import java.awt.*;
import javax.swing.*;
/*
 * Created by JFormDesigner on Mon Apr 25 17:41:25 EDT 2022
 */

public class MainWindow {

    public MainWindow() {
        initComponents();
    }

    private void initComponents() {
        mainFrame = new JFrame();
        d = new JPanel();
        label1 = new JLabel();
        panel1 = new JPanel();
        btnQuestion1 = new JButton();
        btnQuestion2 = new JButton();
        btnQuestion3 = new JButton();
        btnQuestion4 = new JButton();
        btnClear = new JButton();
        scrollPane1 = new JScrollPane();
        textAreaReponse = new JTextArea();
        scrollPane2 = new JScrollPane();
        textArea1 = new JTextArea();

        // ======== mainFrame ========
        {
            Container mainFrameContentPane = mainFrame.getContentPane();
            mainFrameContentPane.setLayout(new BorderLayout());

            // ======== d ========
            {
                d.addPropertyChangeListener(new java.beans.PropertyChangeListener() {
                    @Override
                    public void propertyChange(java.beans.PropertyChangeEvent e) {
                        if ("bord\u0065r".equals(e.getPropertyName()))
                            throw new RuntimeException();
                    }
                });
                d.setLayout(null);

                // ---- label1 ----
                label1.setText("Projet du cours");
                label1.setFont(label1.getFont().deriveFont(label1.getFont().getSize() + 15f));
                d.add(label1);
                label1.setBounds(10, 5, 205, 85);

                // ======== panel1 ========
                {
                    panel1.setLayout(new GridLayout());
                }
                d.add(panel1);
                panel1.setBounds(0, 0, 920, panel1.getPreferredSize().height);

                // ---- btnQuestion1 ----
                btnQuestion1.setText("Question 1");
                d.add(btnQuestion1);
                btnQuestion1.setBounds(10, 100, 205, 60);
                btnQuestion1.addActionListener(e -> {
                    textAreaReponse.setText(App.queryQuestion1());
                });
                // ---- btnQuestion2 ----
                btnQuestion2.setText("Question 2");
                d.add(btnQuestion2);
                btnQuestion2.setBounds(10, 170, 205, 60);
                btnQuestion2.addActionListener(e -> {
                    textAreaReponse.setText(App.queryQuestion2());
                });

                // ---- btnQuestion3 ----
                btnQuestion3.setText("Question 3");
                d.add(btnQuestion3);
                btnQuestion3.setBounds(10, 240, 205, 60);
                btnQuestion3.addActionListener(e -> {
                    textAreaReponse.setText(App.queryQuestion3());
                });
                // ---- btnQuestion4 ----
                btnQuestion4.setText("Question 4");
                d.add(btnQuestion4);
                btnQuestion4.setBounds(10, 310, 205, 60);
                btnQuestion4.addActionListener(e -> {
                    textAreaReponse.setText(App.queryQuestion4());
                });
                // ---- btnClear ----
                btnClear.setText("Clear");
                btnClear.setForeground(Color.red);
                d.add(btnClear);
                btnClear.setBounds(10, 385, 205, 70);
                btnClear.addActionListener(e -> {
                    textAreaReponse.setText("");
                });
                // ======== scrollPane1 ========
                {
                    scrollPane1.setViewportView(textAreaReponse);
                }
                d.add(scrollPane1);
                scrollPane1.setBounds(240, 15, 655, 535);

                // ======== scrollPane2 ========
                {

                    // ---- textArea1 ----
                    textArea1.setText("Jean Khoury\nMahdi Moghadasi\nTian Peng\nGuillaume Pilon");
                    textArea1.setBackground(Color.lightGray);
                    textArea1.setForeground(Color.white);
                    textArea1.setFocusable(false);
                    textArea1.setEditable(false);
                    scrollPane2.setViewportView(textArea1);
                }
                d.add(scrollPane2);
                scrollPane2.setBounds(15, 460, 200, 90);

                {
                    // compute preferred size
                    Dimension preferredSize = new Dimension();
                    for (int i = 0; i < d.getComponentCount(); i++) {
                        Rectangle bounds = d.getComponent(i).getBounds();
                        preferredSize.width = Math.max(bounds.x + bounds.width, preferredSize.width);
                        preferredSize.height = Math.max(bounds.y + bounds.height, preferredSize.height);
                    }
                    Insets insets = d.getInsets();
                    preferredSize.width += insets.right;
                    preferredSize.height += insets.bottom;
                    d.setMinimumSize(preferredSize);
                    d.setPreferredSize(preferredSize);
                    mainFrame.setVisible(true);

                }
            }
            mainFrameContentPane.add(d, BorderLayout.CENTER);
            mainFrame.pack();
            mainFrame.setLocationRelativeTo(mainFrame.getOwner());
        }
    }

    private JFrame mainFrame;
    private JPanel d;
    private JLabel label1;
    private JPanel panel1;
    private JButton btnQuestion1;
    private JButton btnQuestion2;
    private JButton btnQuestion3;
    private JButton btnQuestion4;
    private JButton btnClear;
    private JScrollPane scrollPane1;
    private JTextArea textAreaReponse;
    private JScrollPane scrollPane2;
    private JTextArea textArea1;
}
