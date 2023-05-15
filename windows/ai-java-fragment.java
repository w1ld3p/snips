import java.io.*;
import java.nio.file.*;
import java.security.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Scanner;
import java.util.logging.*;
import org.apache.commons.io.FileUtils;
import org.apache.commons.codec.digest.DigestUtils;

public class Main {
    private static final Logger LOGGER = Logger.getLogger(Main.class.getName());

    public static void main(String[] args) throws IOException {
        Handler fileHandler = new FileHandler("./application.log");
        LOGGER.addHandler(fileHandler);
        SimpleFormatter simple = new SimpleFormatter();
        fileHandler.setFormatter(simple);

        while (true) {
            System.out.println("1. Copy files");
            System.out.println("2. Calculate MD5 hashes");
            System.out.println("3. Exit");
            System.out.print("Please select an action: ");

            Scanner scanner = new Scanner(System.in);
            int action = scanner.nextInt();

            switch (action) {
                case 1:
                    copyFiles();
                    break;
                case 2:
                    calculateMD5();
                    break;
                case 3:
                    LOGGER.info("User selected Exit");
                    System.out.println("Exiting...");
                    return;
                default:
                    LOGGER.warning("Invalid option selected");
                    System.out.println("Invalid option. Please try again.");
            }
        }
    }

    private static void copyFiles() throws IOException {
        Scanner scanner = new Scanner(System.in);
        System.out.println("Enter source directory:");
        String source = scanner.nextLine();
        System.out.println("Enter destination directory:");
        String destination = scanner.nextLine();

        File srcDir = new File(source);
        File destDir = new File(destination);

        if (!srcDir.exists() || !destDir.exists()) {
            LOGGER.severe("Source or destination path does not exist.");
            System.out.println("Source or destination path does not exist.");
            return;
        }

        File[] files = srcDir.listFiles();
        if (files != null) {
            for (int i = 0; i < files.length; i++) {
                FileUtils.copyFileToDirectory(files[i], destDir);
                double progressPercentage = (100.0 * i) / files.length;
                System.out.format("Copied: %d of %d files, %.2f%% completed\n", i, files.length, progressPercentage);
                LOGGER.info(String.format("Copied file %s to %s", files[i].getAbsolutePath(), destDir.getAbsolutePath()));
            }
        }

        System.out.println("Files copied successfully.");
        LOGGER.info("Files copied successfully.");
    }

    private static void calculateMD5() throws IOException {
        System.out.println("Enter directory to calculate MD5 hashes:");
        Scanner scanner = new Scanner(System.in);
        String directory = scanner

