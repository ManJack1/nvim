local jdtls = require("jdtls")

-- 确定配置目录
local function get_config_dir()
  if vim.fn.has("mac") == 1 then
    return "config_mac"
  elseif vim.fn.has("linux") == 1 then
    return "config_linux"
  elseif vim.fn.has("win32") or vim.fn.has("win64") then
    return "config_win"
  else
    error("Unsupported operating system")
  end
end

-- 查找 JDTLS 和启动器
local function find_jdtls_launcher()
  local jdtls_path = vim.fn.expand("~/.local/share/nvim/mason/packages/jdtls")
  local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

  if launcher_jar == "" then
    error("JDTLS launcher jar not found")
  end

  return jdtls_path, launcher_jar
end

-- 主配置设置
local function setup_jdtls()
  local jdtls_path, launcher_jar = find_jdtls_launcher()
  local config_dir = jdtls_path .. "/" .. get_config_dir()

  -- 查找项目根目录
  local root_dir = jdtls.setup.find_root({
    ".git",
    "mvnw",
    "gradlew",
    "pom.xml",
  }) or vim.fn.getcwd()

  local workspace_folder = vim.fn.expand("~/.cache/jdtls/workspace/") .. vim.fn.fnamemodify(root_dir, ":p:h:t")

  -- 收集依赖库
  local function collect_project_libraries()
    local libraries = {}

    -- Maven 本地仓库依赖
    local maven_repo = vim.fn.expand("~/.m2/repository")
    local cs61b_libs = vim.fn.expand("~/OneDrive/Note/CS/cs61b/library-fa24/*.jar")

    -- 添加 Maven 仓库和 CS61B 库
    vim.list_extend(libraries, vim.fn.glob(maven_repo .. "/**/*.jar", true, true))
    vim.list_extend(libraries, vim.fn.glob(cs61b_libs, true, true))

    return libraries
  end

  local config = {
    cmd = {
      "java",
      "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      "-Dosgi.bundles.defaultStartLevel=4",
      "-Declipse.product=org.eclipse.jdt.ls.core.product",
      "-Dlog.protocol=true",
      "-Dlog.level=ALL",
      "-Xmx1g",
      "--add-modules=ALL-SYSTEM",
      "--add-opens",
      "java.base/java.util=ALL-UNNAMED",
      "--add-opens",
      "java.base/java.lang=ALL-UNNAMED",
      "-jar",
      launcher_jar,
      "-configuration",
      config_dir,
      "-data",
      workspace_folder,
    },
    root_dir = root_dir,
    settings = {
      java = {
        project = {
          referencedLibraries = collect_project_libraries(),
        },
        -- 启用完整的依赖项目解析
        configuration = {
          runtimes = {
            {
              name = "JavaSE-17",
              path = vim.fn.expand("~/.sdkman/candidates/java/current"),
            },
          },
        },
      },
    },
    capabilities = vim.lsp.protocol.make_client_capabilities(),
    flags = {
      allow_incremental_sync = true,
    },
    on_attach = function(client, bufnr)
      -- 额外的诊断和设置
      print("JDTLS 已连接!")

      -- 可以添加更多的按键映射或自定义行为
      jdtls.setup.add_commands()
    end,
  }

  require("jdtls").start_or_attach(config)
end

-- 启动配置
setup_jdtls()
