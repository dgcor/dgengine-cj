package dgengine

import cjsfml.system.*
import std.collection.*
import std.fs.*
import std.io.*
import std.math.*
import std.os.*

public class FileUtils {
    public static func initPhysFS(argv0!: ?String = None): Unit {
        PhysFS.`init`(argv0: argv0)
    }

    public static func deinitPhysFS(): Unit {
        PhysFS.deinit()
    }

    public static func gamefileExists(filePath: String): Bool {
        try {
            var path = Path(filePath)
            if (File.exists(path) || Directory.exists(path)) {
                return true
            }
            if (path.extensionName.isSome()) {
                path = path.directoryName?.join(path.fileNameWithoutExtension ?? "") ?? path
                if (File.exists(path) || Directory.exists(path)) {
                    return true
                }
            }
            for (ext in Hooks.archiveExtensions) {
                let path = path.join(ext)
                if (File.exists(path) || Directory.exists(path)) {
                    return true
                }
            }
        } catch (_: Exception) {
            logger.debug("gamefileExists error: ${filePath}")
        }
        logger.debug("gamefile doesn't exist: ${filePath}")
        return false
    }

    // concatenates physfs path and file/folder
    public static func makePhysfsPath(path: String, file: String): String {
        PhysFS.makePhysfsPath(path, file)
    }

    // concatenates local OS path and file/folder
    public static func makeSystemPath(path: String, file: String): String {
        var filePath = path
        if (filePath.isEmpty() == false && filePath.endsWith('\\') == false && filePath.endsWith('/') == false) {
            filePath += PhysFS.dirSeparator
        }
        filePath += file
        return filePath
    }

    // add folder or archive to the search path.
    public static func mount(filePath: String, mountPoint: String, appendToSearchPath: Bool): Bool {
        PhysFS.mount(filePath, mountPoint, appendToSearchPath)
    }

    // remove folder or archive from the search path.
    // only call after all file handles for the search path are closed.
    public static func unmount(filePath: String): Bool {
        PhysFS.unmount(filePath)
    }

    // removes all folders and archives from the search path.
    // only call after all file handles are closed.
    public static func unmountAll(): Unit {
        PhysFS.unmountAll()
    }

    public static func copyDir(dirSrcName: String, dirDstName: String): Bool {
        PhysFS.copyDir(dirSrcName, dirDstName)
    }

    public static func createDir(FilePath: String): Bool {
        let success = PhysFS.mkdir(FilePath)
        logger.debug("createDir (${success}): ${FilePath}")
        return success
    }

    // deletes all files in folder. if deleteRoot is false,
    // the directory "filePath" is empty, but isn't deleted.
    // if the filePath to delete is in a mount point, it will fail.
    public static func deleteAll(filePath: String, deleteRoot!: Bool = true): Bool {
        PhysFS.deleteAll(filePath, deleteRoot: deleteRoot)
    }

    // if the filePath to delete is in a mount point, it will fail.
    public static func deleteFile(filePath: String): Bool {
        let writeDir = PhysFS.writeDir
        let realDir = PhysFS.getRealDir(filePath)
        if (writeDir.isEmpty() == false && realDir.isEmpty() == false) {
            if (writeDir == realDir) {
                return PhysFS.delete(filePath)
            }
        }
        return false
    }

    public static func exists(filePath: String): Bool {
        PhysFS.exists(filePath)
    }

    // get list of dirs in path.
    public static func getDirList(path: String, onlyWritableDirs!: Bool): ArrayList<String> {
        PhysFS.getDirList(path, onlyWritableDirs: onlyWritableDirs)
    }

    // get list of fileNames or fullPaths in path
    public static func getFileList(path: String, fileExt: String, getFullPath!: Bool): ArrayList<String> {
        PhysFS.getFileList(path, fileExt, getFullPath: getFullPath)
    }

    public static func getFileName(filePath: String): String {
        Path(filePath).fileName ?? String.empty
    }

    public static func getFileNameWithoutExt(filePath: String): String {
        try {
            let path = Path(filePath)
            if (let Some(name) <- path.fileNameWithoutExtension) {
                return name
            }
            if (let Some(name) <- path.fileName) {
                return name
            }
        } catch (_: Exception) {
        }
        return String.empty
    }

    public static func getFileExtension(filePath: String): String {
        if (let Some(ext) <- Path(filePath).extensionName) {
            return ".${ext}"
        } else if (filePath.endsWith(".")) {
            return "."
        }
        return String.empty
    }

    public static func getFilePath(filePath: String): String {
        Path(filePath).directoryName?.toString() ?? String.empty
    }

    public static func readBytes(filePath: String, startPosition!: Int64 = 0, maxNumBytes!: Int64 = 0xFFFFFFFF): Array<Byte> {
        var data = Array<Byte>()
        try (ifs = PhysFSStream(filePath)) {
            let fileSize = ifs.length

            let startPosition = min(startPosition, fileSize)
            let maxNumBytes = min(maxNumBytes, fileSize)
            let endPosition = min(startPosition + maxNumBytes, fileSize)

            let size = endPosition - startPosition
            if (size == 0) {
                logger.debug("readBytes empty range: ${filePath}")
                return data
            }

            data = Array<Byte>(size, item: 0)
            if (startPosition > 0) {
                ifs.seek(Begin(startPosition))
            }
            ifs.read(data)
        } catch (ex: Exception) {
            logger.debug("readBytes error: ${filePath}")
        }
        return data
    }

    public static func readText(filePath: String): String {
        try (ifs = PhysFSStream(filePath)) {
            let data = Array<Byte>(ifs.length, item: 0)
            ifs.read(data)
            return String.fromUtf8(data)
        } catch (_: Exception) {
            logger.debug("readText error: ${filePath}")
        }
        return String.empty
    }

    public static prop saveDir: String {
        get() {
            let writeDir = PhysFS.writeDir
            if (writeDir.isEmpty() == false) {
                return makeSystemPath(writeDir, "")
            }
            return writeDir
        }
    }

    public static func setSaveDir(dirName: String): Bool {
        var userDir = String.empty
        try {
            var portablePath = currentDir().info.path.join("portable")
            if (Directory.exists(portablePath) == true) {
                portablePath = portablePath.join(dirName)
                userDir = portablePath.toString()
                Directory.create(portablePath, recursive: true)
            }
        } catch (_: Exception) {}

        if (userDir.isEmpty()) {
            userDir = PhysFS.getPrefDir("DGEngine", dirName)
        }
        if (userDir.isEmpty()) {
            return false
        }
        return PhysFS.setWriteDir(userDir)
    }

    // creates path if it doesn't exist
    public static func saveBytes(filePath: String, bytes: Array<Byte>): Bool {
        try {
            var path = Path(filePath)
            if (File.exists(path) || Directory.exists(path)) {
                return true
            }
            if (let Some(dir) <- path.directoryName) {
                createDir(dir.toString())
            }
            return PhysFS.writeBytes(filePath, bytes)
        } catch (_: Exception) {
            logger.debug("saveBytes error: ${filePath}")
        }
        logger.warn("saveBytes failed: ${filePath}")
        return false
    }

    // creates path if it doesn't exist
    public static func saveText(filePath: String, str: String): Bool {
        unsafe {
            let rawStr = str.getRaw()
            try {
                return saveBytes(filePath, rawStr.array)
            } finally {
                str.releaseRaw(rawStr)
            }
        }
    }

    // writes file to a filesystem path (not to physfs's write dir path).
    public static func exportFile(infilePath: String, outfilePath: String): Bool {
        try {
            let inPath = Path(infilePath)
            var outPath = Path(outfilePath)

            if (Directory.exists(outPath) == true) {
                if (let Some(fileName) <- inPath.fileName) {
                    outPath = outPath.join(fileName)
                }
            }

            let data = readBytes(infilePath)
            File.writeTo(outPath, data, openOption: OpenOption.CreateOrTruncate(true))
            return true
        } catch (ex: Exception) {
            logger.warn("exportFile failed: \"${infilePath}\" -> \"${outfilePath}\"")
        }
        return false
    }
}
