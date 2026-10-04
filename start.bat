@echo off
setlocal
rem 注意：本文件必须以 ANSI(GBK) 编码保存，否则中文将显示乱码
rem Note: this file must be saved in ANSI/GBK encoding
title Chrome个人资料迁移工具 / Chrome Profile Migration Tool

rem ==========================================
rem Chrome 个人资料迁移工具
rem 支持语言 / Languages: 简体中文 / English
rem ==========================================

rem ==========================================
rem Step 1：权限校验（提示信息为中英双语 / Bilingual messages）
rem ==========================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误 - 权限不足] / [ERROR - Insufficient Privileges]
    echo 本脚本需要“管理员权限”来执行软链接创建和文件剪切操作。
    echo This script requires "administrator privileges" to create junction links and move files.
    echo 请右键点击本脚本，选择“以管理员身份运行”。
    echo Right-click this script and choose "Run as administrator".
    pause
    exit /b
)

rem ==========================================
rem Step 2：语言选择 / Language Selection
rem ==========================================
:LANG_MENU
cls
echo =======================================================
echo            语言选择 / Language Selection
echo =======================================================
echo   1. 简体中文 (Simplified Chinese)
echo   2. English
echo =======================================================
set "lang_choice="
set /p lang_choice="请输入选项 / Enter an option (1-2): "
if not defined lang_choice exit /b

if "%lang_choice%"=="1" set "LANG=CN"
if "%lang_choice%"=="2" set "LANG=EN"
if not defined LANG (
    echo 无效输入，请输入 1 或 2。/ Invalid input, please enter 1 or 2.
    timeout /t 2 >nul
    goto LANG_MENU
)

if "%LANG%"=="CN" goto SET_CN

rem ------------------------------------------
rem English UI texts
rem ------------------------------------------
:SET_EN
title Chrome Profile Migration Tool
set "T_MENU_TITLE=Chrome User Data Migration Tool"
set "T_M1=1. Migrate Chrome profile (C: drive -> another drive)"
set "T_M2=2. Restore migration (back to the original path)"
set "T_M3=3. Exit"
set "T_M_PROMPT=Enter an option (1-3): "
set "T_INVALID=[ERROR] Invalid input, please try again."
set "T_MIG_H=[ Migrate Chrome Profile ]"
set "T_MIG_NF1=[INFO] Could not auto-locate the default Chrome profile directory."
set "T_MIG_NF2=Open Chrome and enter: chrome://version/ in the address bar."
set "T_MIG_NF3=Find the 'Profile Path' entry, then copy and paste it below."
set "T_MIG_SRC_P=Enter the original User Data path: "
set "T_MIG_NOEXIST=[ERROR] The path does not exist. Please check and try again."
set "T_MIG_FOUND=[OK] Original path detected: "
set "T_ISLINK=[ERROR] This path is already a junction link. It may have been migrated before."
set "T_CHOOSE_T=Select the target path:"
set "T_T1=1. Use the default target path (D:\Program Files (x86)\Google Chrome\User Data)"
set "T_T2=2. Enter or drag and drop the target path"
set "T_T3=3. Back to main menu"
set "T_T_PROMPT=Enter an option (1-3): "
set "T_T_MKFAIL=[ERROR] Failed to create the default target path. Please enter it manually."
set "T_TOPT=[ERROR] Invalid option."
set "T_T_MANUAL=Enter or drag and drop the target path (data will be moved under it): "
set "T_T_CREATING=[INFO] The target path does not exist. Creating it..."
set "T_T_MKFAIL2=[ERROR] Failed to create the target path. Please check the input."
set "T_CONFIRM=[ Confirmation ]"
set "T_LBL_SRC=Original path: "
set "T_LBL_DST=Target path: "
set "T_WARN=[!!! WARNING !!!]"
set "T_WARN_MIG1=Make sure Chrome is COMPLETELY closed before migrating!"
set "T_WARN_MIG2=Ensure no chrome.exe process is running in Task Manager."
set "T_MOVING=Moving files to the target path. This may take a few minutes, please wait..."
set "T_MOVEFAIL1=[ERROR] Files still remain in the original directory and cannot be removed! (Chrome is probably not fully closed)"
set "T_MOVEFAIL2=Migration aborted. Some files may have been moved to the target path already. Check manually, or reboot and try again."
set "T_MKLINKING=Creating the directory junction (mklink /j)..."
set "T_MKLINKFAIL=[ERROR] Failed to create the junction link!"
set "T_LBL_LINK=Junction status: "
set "T_LBL_INI=Config file created: "
set "T_MIG_OK=[OK] Chrome profile has been migrated successfully!"
set "T_RES_H=[ Restore Chrome Profile ]"
set "T_RES_NOINI=[ERROR] Could not find the config file 'chromeProfileMigration.ini'!"
set "T_RES_NOINI2=Possible causes: the junction link is broken, or the config file was deleted."
set "T_RES_FOUND=Config file found!"
set "T_RES_SRC=Original path (from config): "
set "T_RES_DST=Data path resolved: "
set "T_WARN_RES=Make sure Chrome is COMPLETELY closed before restoring!"
set "T_RES_NL1=[ERROR] The original path "
set "T_RES_NL2= is not a junction link. Cannot restore safely!"
set "T_RM_LINK=Removing the junction link..."
set "T_RESTORING=Restoring files to the original path. Please wait..."
set "T_RES_OK=[OK] Chrome profile has been fully restored to the original path!"
goto LANG_READY

rem ------------------------------------------
rem 简体中文界面文本
rem ------------------------------------------
:SET_CN
title Chrome个人资料迁移工具
set "T_MENU_TITLE=Chrome 个人资料目录迁移工具"
set "T_M1=1. 开始迁移Chrome个人资料 (C盘 -> 其他盘)"
set "T_M2=2. 恢复迁移 (还原至原始路径)"
set "T_M3=3. 退出脚本"
set "T_M_PROMPT=请输入选项序号并回车 (1-3): "
set "T_INVALID=[错误] 无效的输入，请重新选择！"
set "T_MIG_H=【开始迁移Chrome个人资料】"
set "T_MIG_NF1=[提示] 未能自动找到默认的Chrome个人资料目录。"
set "T_MIG_NF2=请打开Chrome浏览器，在地址栏输入: chrome://version/"
set "T_MIG_NF3=找到“个人资料路径”，复制并粘贴到下方。"
set "T_MIG_SRC_P=请输入原始User Data路径: "
set "T_MIG_NOEXIST=[错误] 输入的路径不存在，请检查后重试！"
set "T_MIG_FOUND=[成功] 自动检索到原路径: "
set "T_ISLINK=[错误] 检测到该路径已经是软链接，可能之前已经迁移过！"
set "T_CHOOSE_T=请选择目标路径:"
set "T_T1=1. 使用默认目标路径 (D:\Program Files (x86)\Google Chrome\User Data)"
set "T_T2=2. 手动输入或拖拽目标路径"
set "T_T3=3. 返回主菜单"
set "T_T_PROMPT=请输入选项 (1-3): "
set "T_T_MKFAIL=[错误] 自动创建默认目标路径失败！请尝试手动输入。"
set "T_TOPT=[错误] 无效选项！"
set "T_T_MANUAL=请输入或拖拽目标路径 (将迁移至此目录下): "
set "T_T_CREATING=[提示] 目标路径不存在，尝试自动创建..."
set "T_T_MKFAIL2=[错误] 创建目标路径失败！请检查输入是否合法。"
set "T_CONFIRM=【确认信息】"
set "T_LBL_SRC=原始路径: "
set "T_LBL_DST=目标路径: "
set "T_WARN=[!!! 警告 !!!]"
set "T_WARN_MIG1=开始迁移前，请务必彻底关闭Chrome浏览器！"
set "T_WARN_MIG2=确保任务管理器中没有任何 chrome.exe 进程。"
set "T_MOVING=正在安全转移文件至目标路径，此过程可能需要几分钟，请耐心等待..."
set "T_MOVEFAIL1=[错误] 原始目录仍有文件无法移除！(通常因为Chrome未彻底关闭)"
set "T_MOVEFAIL2=迁移被迫中止，但部分文件可能已移动至目标路径，请手动排查或重启电脑后重试。"
set "T_MKLINKING=正在创建目录软链接 (mklink /j)..."
set "T_MKLINKFAIL=[错误] 软链接创建失败！"
set "T_LBL_LINK=软链接状态: "
set "T_LBL_INI=配置文件已生成: "
set "T_MIG_OK=[成功] Chrome 个人资料已成功迁移！"
set "T_RES_H=【恢复Chrome个人资料】"
set "T_RES_NOINI=[错误] 未能找到 chromeProfileMigration.ini 配置文件！"
set "T_RES_NOINI2=可能原因：软链接已被破坏，或配置文件被删除。"
set "T_RES_FOUND=找到配置文件！"
set "T_RES_SRC=读取到原始路径: "
set "T_RES_DST=解析出数据路径: "
set "T_WARN_RES=恢复前，请务必彻底关闭Chrome浏览器！"
set "T_RES_NL1=[错误] 原始路径 "
set "T_RES_NL2= 并非软链接，无法安全恢复！"
set "T_RM_LINK=正在删除软链接..."
set "T_RESTORING=正在还原文件至原始路径，请耐心等待..."
set "T_RES_OK=[成功] Chrome个人资料已彻底恢复至原始路径！"

:LANG_READY
setlocal enabledelayedexpansion

rem ==========================================
rem Step 3：主菜单交互
rem ==========================================
:MAIN_MENU
cls
echo =======================================================
echo               !T_MENU_TITLE!
echo =======================================================
echo   !T_M1!
echo   !T_M2!
echo   !T_M3!
echo =======================================================
set "choice="
set /p choice="!T_M_PROMPT!"
if not defined choice goto EXIT_SCRIPT

if "!choice!"=="1" goto MIGRATE
if "!choice!"=="2" goto RESTORE
if "!choice!"=="3" goto EXIT_SCRIPT

echo !T_INVALID!
timeout /t 2 >nul
goto MAIN_MENU


rem ==========================================
rem Step 4：迁移逻辑 (输入1)
rem ==========================================
:MIGRATE
cls
echo =======================================================
echo                 !T_MIG_H!
echo =======================================================
rem 1. 自动检索路径
set "SRC_PATH=%localappdata%\Google\Chrome\User Data"

if not exist "!SRC_PATH!" (
    echo !T_MIG_NF1!
    echo !T_MIG_NF2!
    echo !T_MIG_NF3!
    echo -------------------------------------------------------
    set /p SRC_PATH="!T_MIG_SRC_P!"
    
    rem 自动去除双引号
    set SRC_PATH=!SRC_PATH:"=!
    rem 自动去除末尾可能存在的反斜杠
    if "!SRC_PATH:~-1!"=="\" set "SRC_PATH=!SRC_PATH:~0,-1!"
    rem 自动剔除末尾的 \Default
    if /i "!SRC_PATH:~-8!"=="\Default" set "SRC_PATH=!SRC_PATH:~0,-8!"

    if not exist "!SRC_PATH!" (
        echo !T_MIG_NOEXIST!
        pause >nul
        goto MAIN_MENU
    )
) else (
    echo !T_MIG_FOUND!!SRC_PATH!
)

rem 校验是否已经是软链接
dir /al "!SRC_PATH!" >nul 2>&1
if !errorlevel! equ 0 (
    echo !T_ISLINK!
    pause >nul
    goto MAIN_MENU
)

:CHOOSE_TARGET
echo -------------------------------------------------------
echo !T_CHOOSE_T!
echo   !T_T1!
echo   !T_T2!
echo   !T_T3!
echo -------------------------------------------------------
set "t_choice="
set /p t_choice="!T_T_PROMPT!"
if not defined t_choice goto MAIN_MENU

if "!t_choice!"=="1" (
    set "DST_PATH=D:\Program Files (x86)\Google Chrome\User Data"
    if not exist "!DST_PATH!" (
        mkdir "!DST_PATH!" 2>nul
        if !errorlevel! neq 0 (
            echo !T_T_MKFAIL!
            goto MANUAL_TARGET
        )
    )
    goto DO_MIGRATE
) else if "!t_choice!"=="2" (
    goto MANUAL_TARGET
) else if "!t_choice!"=="3" (
    goto MAIN_MENU
) else (
    echo !T_TOPT!
    goto CHOOSE_TARGET
)

:MANUAL_TARGET
echo -------------------------------------------------------
set /p DST_PATH="!T_T_MANUAL!"
rem 自动去除双引号和尾部斜杠
set DST_PATH=!DST_PATH:"=!
if "!DST_PATH:~-1!"=="\" set "DST_PATH=!DST_PATH:~0,-1!"

if not exist "!DST_PATH!" (
    echo !T_T_CREATING!
    mkdir "!DST_PATH!" 2>nul
    if !errorlevel! neq 0 (
        echo !T_T_MKFAIL2!
        pause >nul
        goto CHOOSE_TARGET
    )
)

:DO_MIGRATE
echo -------------------------------------------------------
echo !T_CONFIRM!
echo !T_LBL_SRC!!SRC_PATH!
echo !T_LBL_DST!!DST_PATH!
echo.
echo !T_WARN!
echo !T_WARN_MIG1!
echo !T_WARN_MIG2!
pause

echo.
echo !T_MOVING!
rem 使用 robocopy 剪切文件
robocopy "!SRC_PATH!" "!DST_PATH!" /E /MOVE /COPYALL /R:3 /W:1 /MT:16 >nul

rem 确认原目录已空并删除空壳，防止软链接创建失败
if exist "!SRC_PATH!" (
    rmdir /s /q "!SRC_PATH!" >nul 2>&1
    if exist "!SRC_PATH!" (
        echo !T_MOVEFAIL1!
        echo !T_MOVEFAIL2!
        pause >nul
        goto MAIN_MENU
    )
)

echo !T_MKLINKING!
mklink /j "!SRC_PATH!" "!DST_PATH!" >nul
if !errorlevel! neq 0 (
    echo !T_MKLINKFAIL!
    pause >nul
    goto MAIN_MENU
)

rem 生成配置文件至目标目录
echo !SRC_PATH!> "!DST_PATH!\chromeProfileMigration.ini"

echo -------------------------------------------------------
echo !T_MIG_OK!
echo !T_LBL_LINK!!SRC_PATH! =^> !DST_PATH!
echo !T_LBL_INI!!DST_PATH!\chromeProfileMigration.ini
pause
goto MAIN_MENU


rem ==========================================
rem Step 5：恢复迁移逻辑 (输入2)
rem ==========================================
:RESTORE
cls
echo =======================================================
echo                 !T_RES_H!
echo =======================================================
set "INI_FILE="
set "DEFAULT_SRC=%localappdata%\Google\Chrome\User Data"

rem 解析原始目录软链接的指向，全自动定位目标目录中的ini文件
dir /al "!DEFAULT_SRC!\.." >nul 2>&1
if !errorlevel! equ 0 (
    for /f "tokens=2 delims=[]" %%a in ('dir /al "!DEFAULT_SRC!\.." ^| findstr /i "User Data" ^| findstr /v "findstr"') do (
        set "TARGET_DIR=%%a"
        if exist "!TARGET_DIR!\chromeProfileMigration.ini" (
            set "INI_FILE=!TARGET_DIR!\chromeProfileMigration.ini"
        ) else if exist "!TARGET_DIR!\chrome个人资料迁移.ini" (
            set "INI_FILE=!TARGET_DIR!\chrome个人资料迁移.ini"
        )
    )
)

rem 尝试保底路径
if not defined INI_FILE (
    if exist "D:\Program Files (x86)\Google Chrome\User Data\chromeProfileMigration.ini" (
        set "INI_FILE=D:\Program Files (x86)\Google Chrome\User Data\chromeProfileMigration.ini"
    ) else if exist "D:\Program Files (x86)\Google Chrome\User Data\chrome个人资料迁移.ini" (
        set "INI_FILE=D:\Program Files (x86)\Google Chrome\User Data\chrome个人资料迁移.ini"
    )
)

rem 核心判断：未找到文件则报错并返回
if not exist "!INI_FILE!" (
    echo !T_RES_NOINI!
    echo !T_RES_NOINI2!
    pause >nul
    goto MAIN_MENU
)

rem 读取配置文件获取原始路径
set /p RESTORE_SRC=<"!INI_FILE!"

rem 提取配置文件所在目录作为目标路径
for %%I in ("!INI_FILE!") do set "RESTORE_DST=%%~dpI"
if "!RESTORE_DST:~-1!"=="\" set "RESTORE_DST=!RESTORE_DST:~0,-1!"

echo !T_RES_FOUND!
echo !T_RES_SRC!!RESTORE_SRC!
echo !T_RES_DST!!RESTORE_DST!
echo -------------------------------------------------------
echo !T_WARN!
echo !T_WARN_RES!
pause

rem 二次校验原始路径是否为软链接
dir /al "!RESTORE_SRC!" >nul 2>&1
if !errorlevel! neq 0 (
    echo !T_RES_NL1!!RESTORE_SRC!!T_RES_NL2!
    pause >nul
    goto MAIN_MENU
)

echo.
echo !T_RM_LINK!
rmdir "!RESTORE_SRC!" >nul 2>&1

echo !T_RESTORING!
rem 提前删除配置文件，防止将其转移回C盘
del /f /q "!INI_FILE!" >nul 2>&1

rem 使用 robocopy 将文件剪切回去
robocopy "!RESTORE_DST!" "!RESTORE_SRC!" /E /MOVE /COPYALL /R:3 /W:1 /MT:16 >nul

rem 移除空壳目录
if exist "!RESTORE_DST!" (
    rmdir /s /q "!RESTORE_DST!" >nul 2>&1
)

echo -------------------------------------------------------
echo !T_RES_OK!
pause
goto MAIN_MENU


rem ==========================================
rem Step 6：辅助功能
rem ==========================================
:EXIT_SCRIPT
exit /b
