package com.rishabhroy.MineCam;

import com.rishabhroy.MineCam.Util.ProcessOutputRedirectThread;
import com.rishabhroy.MineCam.Util.Util;

import java.awt.*;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;

public class HidWrapper {
    public static String minecamhelperpath;
    public static Robot robot;
    private static volatile boolean canSendHelperUpdate = true;

    // ponytail: one long-lived helper process fed commands over stdin, instead of
    // spawning (and never reaping) a fresh process per mouse/key event. The old
    // per-event exec() approach built up zombie processes and leaked pipe FDs,
    // which is why input eventually stopped firing or fired minutes late.
    private static Process helperProcess;
    private static BufferedWriter helperStdin;

    static synchronized void setupMacHelper() {
        HidWrapper.minecamhelperpath = Util.getResourceAsFile("assets/minecam/MineCamHelper", ".MineCamHelper").getAbsolutePath();
        try {
            Runtime.getRuntime().exec("chmod +x " + minecamhelperpath).waitFor();
            HidWrapper.helperProcess = new ProcessBuilder(minecamhelperpath).start();
            HidWrapper.helperStdin = new BufferedWriter(new OutputStreamWriter(helperProcess.getOutputStream(), StandardCharsets.UTF_8));
            new ProcessOutputRedirectThread(helperProcess.getInputStream()).start();
            new ProcessOutputRedirectThread(helperProcess.getErrorStream()).start();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        Util.log("HID: Mac Helper Setup");
    }

    private static synchronized void sendHelperCommand(String command) {
        try {
            helperStdin.write(command);
            helperStdin.newLine();
            helperStdin.flush();
        }
        catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void setupHid() {
        Util.log("HID: Starting HID");
        if (Util.IS_MAC) {
            setupMacHelper();
        }
        else {
            System.setProperty("java.awt.headless", "false");
            try {
                robot = new Robot();
                Util.log("HID: Robot instance setup");
            } catch (AWTException e) {
                e.printStackTrace();
            }
        }

        Util.log("HID: HID Setup Complete");
    }

    public static void delay(int ms) {
        if (Util.IS_MAC) {
            canSendHelperUpdate = false;
            Thread thread = new Thread(() -> {
                try {
                    Thread.sleep(ms);
                }
                catch (Exception e) {
                    e.printStackTrace();
                }
                canSendHelperUpdate = true;
            });
            thread.start();
            try {
                Thread.sleep(ms);
            }
            catch (Exception e) {

            }
        }
        else {
            robot.delay(ms);
        }
    }

    public static void runDelayedTask(int ms, Thread run) {
        if (Util.IS_MAC) {
            canSendHelperUpdate = false;
            Thread thread = new Thread(() -> {
                try {
                    Thread.sleep(ms);
                }
                catch (Exception e) {
                    e.printStackTrace();
                }
                canSendHelperUpdate = true;
                run.start();
            });
            thread.start();
        }
        else {
            Thread thread = new Thread(() -> {
                robot.delay(ms);
                run.start();
            });
            thread.start();
        }
    }

    public static void mousePress(int input, String button) {
        if (Util.IS_MAC) {
            if (canSendHelperUpdate) {
                sendHelperCommand("mouse 0 0 " + button + " true false false");
            }
        }
        else {
            robot.mousePress(input);
        }
    }

    public static void mouseRelease(int input, String button) {
        if (Util.IS_MAC) {
            if (canSendHelperUpdate) {
                sendHelperCommand("mouse 0 0 " + button + " false true false");
            }
        }
        else {
            robot.mouseRelease(input);
        }
    }

    public static void mouseMove(int x, int y) {
        if (Util.IS_MAC) {
            if (canSendHelperUpdate) {
                sendHelperCommand("mouse " + x + " " + y + " left false false true");
            }
        }
        else {
            robot.mouseMove(x, y);
        }
    }

    public static void keyPress(int input, String button) {
        if (Util.IS_MAC) {
            if (canSendHelperUpdate) {
                sendHelperCommand("keyboard " + button + " true");
            }
        }
        else {
            robot.keyPress(input);
        }
    }

    public static void keyRelease(int input, String button) {
        if (Util.IS_MAC) {
            if (canSendHelperUpdate) {
                sendHelperCommand("keyboard " + button + " false");
            }
        }
        else {
            robot.keyRelease(input);
        }
    }

}
