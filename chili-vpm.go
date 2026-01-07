package main

import (
  "bytes"
  "crypto/sha1"
  "errors"
  "fmt"
  "io"
  "os"
  "os/exec"
  "path/filepath"
  "sort"
  "strings"
  "time"
  "strconv"
)

// Constantes para cores ANSI
const (
    Reset   = "\x1b[0m"
    Bold    = "\x1b[1m"
    Red     = "\x1b[31m"
    Green   = "\x1b[32m"
    Yellow  = "\x1b[33m"
    Blue    = "\x1b[34m"
    Magenta = "\x1b[35m"
    Cyan    = "\x1b[36m"
    White   = "\x1b[37m"
)

const version = "1.3.0"

type Command struct {
  Name string
  Aliases []string
  Args string
  Desc string
  Run func(args []string) error
}

var commands []*Command

func main() {
  if err := run(); err != nil {
    fmt.Fprintf(os.Stderr, Red+Bold+"erro:"+Reset+" %v\n", err)
    os.Exit(1)
  }
}

func run() error {
  if len(os.Args) < 2 {
    printHelp()
    return errors.New("nenhum subcomando informado")
  }
  if err := ensureBinaries(); err != nil {
    return err
  }
  initCommands()

  sub := os.Args[1]
  args := os.Args[2:]

  switch sub {
  case "help", "-h", "--help":
    printHelp()
    return nil
  case "version":
    fmt.Println("chili-vpm", version)
    return nil
  }

  c := findCommand(sub)
  if c == nil {
    printHelp()
    return fmt.Errorf("subcomando desconhecido: %s", sub)
  }

  return c.Run(args)
}

func ensureBinaries() error {
  bins := []string{"xbps-install","xbps-query","xbps-remove","xbps-alternatives","xbps-reconfigure"}
  var miss []string
  for _, b := range bins {
    if _, err := exec.LookPath(b); err != nil {
      miss = append(miss, b)
    }
  }
  if len(miss) > 0 {
    return fmt.Errorf("faltam binários: %s", strings.Join(miss,", "))
  }
  return nil
}

func initCommands() {
  commands = []*Command{

   {
     Name: "log",
     Aliases: []string{"svlog", "svlogtail"},
     Args: "<service> [nlines]",
     Desc: "Show logs (auto: runit, journalctl, /var/log)",
     Run: func(a []string) error {
       if len(a) < 1 { return argErr("log <service> [nlines]") }

       svc := a[0]
       n := 50
       if len(a) > 1 {
           if x, err := strconv.Atoi(a[1]); err == nil {
               n = x
           }
       }

       return svLogTailAuto(svc, n)
     },
   },

   {
     Name: "start",
     Aliases: []string{"up"},
     Args: "<service>",
     Desc: "Start a runit service",
     Run: func(a []string) error {
       if len(a) < 1 { return argErr("start <service>") }
       return svStart(a[0])
     },
   },

   {
     Name: "stop",
     Aliases: []string{"down"},
     Args: "<service>",
     Desc: "Stop a runit service",
     Run: func(a []string) error {
       if len(a) < 1 { return argErr("stop <service>") }
       return svStop(a[0])
     },
   },

   {
     Name: "restart",
     Aliases: []string{"rs"},
     Args: "<service>",
     Desc: "Restart a runit service",
     Run: func(a []string) error {
       if len(a) < 1 { return argErr("restart <service>") }
       return svRestart(a[0])
     },
   },

   {
     Name: "status",
     Aliases: []string{"st"},
     Args: "<service>",
     Desc: "Show service status",
     Run: func(a []string) error {
       if len(a) < 1 { return argErr("status <service>") }
       return svStatus(a[0])
     },
   },

   {
     Name: "enable",
     Aliases: []string{"en"},
     Args: "<service>",
     Desc: "Enable service in default runsvdir",
     Run: func(a []string) error {
       if len(a) < 1 { return argErr("enable <service>") }
       return svEnable(a[0])
     },
   },

   {
     Name: "disable",
     Aliases: []string{"dis"},
     Args: "<service>",
     Desc: "Disable service from runsvdir",
     Run: func(a []string) error {
       if len(a) < 1 { return argErr("disable <service>") }
       return svDisable(a[0])
     },
   },

   {
     Name:    "services",
     Aliases: []string{"sv", "vsv"},
     Args:    "",
     Desc:    "List runit services (like vsv)",
     Run: func(a []string) error {
       return runVSV()
     },
   },

    {"sync", nil, "", "Synchronize remote repository data",
      func(a []string) error { return runXB("xbps-install", "-S") }},

    {"update", []string{"up"}, "", "Update the system",
      func(a []string) error { return runXB("xbps-install", "-Syu") }},

    {"listrepos", []string{"lr","repolist","rl"}, "", "List configured repositories",
      func(a []string) error { return runQ("-L") }},

    {"addrepo", nil, "<url>", "Add an additional repository", addRepo},

    {"info", nil, "<pkg>", "Show information about <package>",
      func(a []string) error {
        if len(a)==0 { return argErr("info <pkg>") }
        return runQ(append([]string{"-R"}, a...)...)
      }},

    {"filelist", []string{"fl"}, "<pkg>", "Show file-list of <package>",
      func(a []string) error {
        if len(a)==0 { return argErr("filelist <pkg>") }
        return runQ(append([]string{"-f"}, a...)...)
      }},

    {"deps", nil, "<pkg>", "Show dependencies for <package>",
      func(a []string) error {
        if len(a)==0 { return argErr("deps <pkg>") }
        return runQ(append([]string{"-x"}, a...)...)
      }},

    {"reverse", []string{"rv"}, "<pkg>", "Show reverse dependencies",
      func(a []string) error {
        if len(a)==0 { return argErr("reverse <pkg>") }
        return runQ(append([]string{"-X"}, a...)...)
      }},

    {"search", []string{"s"}, "<name>", "Search for package by name",
      func(a []string) error {
        if len(a)==0 { return argErr("search <name>") }
        return runQ(append([]string{"-Rs"}, a...)...)
      }},

    {"searchfile", []string{"sf"}, "<file>", "Search for file",
      func(a []string) error {
        if len(a)==0 { return argErr("searchfile <file>") }
        return runQ(append([]string{"-o"}, a...)...)
      }},

    {"list", []string{"ls"}, "", "List installed packages",
      func(a []string) error { return runQ("-l") }},

    {"install", []string{"i"}, "<pkg(s)>", "Install package(s)",
      func(a []string) error {
        if len(a)==0 { return argErr("install <pkg>") }
        return runXB("xbps-install", append([]string{"-S"}, a...)...)
      }},

    {"devinstall", []string{"di"}, "<pkg>", "Install + devel package",
      func(a []string) error {
        if len(a)==0 { return argErr("devinstall <pkg>") }
        var pkgs []string
        for _, p := range a { pkgs = append(pkgs, p, p+"-devel") }
        return runXB("xbps-install", append([]string{"-S"}, pkgs...)...)
      }},

    {"forceinstall", []string{"fi"}, "<pkg>", "Force install",
      func(a []string) error {
        if len(a)==0 { return argErr("forceinstall <pkg>") }
        return runXB("xbps-install", append([]string{"-f"}, a...)...)
      }},

    {"remove", nil, "<pkg>", "Remove package(s)",
      func(a []string) error {
        if len(a)==0 { return argErr("remove <pkg>") }
        return runXB("xbps-remove", a...)
      }},

    {"removerecursive", nil, "<pkg>", "Recursive remove",
      func(a []string) error {
        if len(a)==0 { return argErr("removerecursive <pkg>") }
        return runXB("xbps-remove", append([]string{"-R"}, a...)...)
      }},

    {"listalternatives", []string{"la"}, "", "List alternative candidates",
      func(a []string) error { return runXB("xbps-alternatives", "-l") }},

    {"setalternative", []string{"sa"}, "<pkg>", "Set alternative",
      func(a []string) error {
        if len(a)==0 { return argErr("setalternative <pkg>") }
        return runXB("xbps-alternatives", append([]string{"-s"}, a...)...)
      }},

    {"reconfigure", []string{"rc"}, "<pkg>", "Re-configure package",
      func(a []string) error {
        if len(a)==0 { return argErr("reconfigure <pkg>") }
        return runXB("xbps-reconfigure", a...)
      }},

    {"cleanup", []string{"cl"}, "", "Clean cache directory",
      func(a []string) error { return runXB("xbps-install", "-Scc") }},

    {"autoremove", []string{"ar"}, "", "Remove orphaned packages",
      func(a []string) error { return runXB("xbps-remove", "-o") }},

    {"whatprovides", []string{"wp"}, "<file>", "Search package containing file",
      func(a []string) error {
        if len(a)==0 { return argErr("whatprovides <file>") }
        return runQ(append([]string{"-S"}, a...)...)
      }},
  }

  sort.Slice(commands, func(i,j int) bool { return commands[i].Name < commands[j].Name })
}

func argErr(s string) error { return fmt.Errorf("uso: chili-vpm %s", s) }

func findCommand(n string)*Command{
  for _,c := range commands {
    if c.Name == n { return c }
    for _,a := range c.Aliases {
      if a == n { return c }
    }
  }
  return nil
}

func runXB(bin string, args ...string) error {
  fmt.Fprintf(os.Stderr, Cyan+">>> %s %s"+Reset+"\n", bin, strings.Join(args," "))
  cmd := exec.Command(bin, args...)
  cmd.Stdin=os.Stdin; cmd.Stdout=os.Stdout; cmd.Stderr=os.Stderr
  return cmd.Run()
}

func runQ(args ...string) error {
  fmt.Fprintf(os.Stderr, Cyan+">>> xbps-query %s"+Reset+"\n", strings.Join(args," "))

  cmd := exec.Command("xbps-query", args...)
  var buf bytes.Buffer

  cmd.Stdout=&buf
  cmd.Stderr=os.Stderr
  cmd.Stdin=os.Stdin

  if err := cmd.Run(); err != nil {
    os.Stdout.Write(buf.Bytes())
    return err
  }

  colorizeQuery(os.Stdout, buf.Bytes())
  return nil
}

func colorizeQuery(w io.Writer, data []byte) {
  for _, line := range strings.Split(string(data), "\n") {
    s := strings.TrimSpace(line)
    if s == "" { continue }

    switch {
    case strings.HasPrefix(s, "pkgname"):
      fmt.Fprintln(w, Bold+Yellow+s+Reset)
    case strings.HasPrefix(s, "pkgver"):
      fmt.Fprintln(w, Bold+Green+s+Reset)
    case strings.HasPrefix(s, "repository"):
      fmt.Fprintln(w, Cyan+s+Reset)
    case strings.HasPrefix(s, "filename"):
      fmt.Fprintln(w, Magenta+s+Reset)
    case strings.HasPrefix(s, "description"),
         strings.HasPrefix(s, "short_desc"):
      fmt.Fprintln(w, Green+s+Reset)
    default:
      fmt.Fprintln(w, s)
    }
  }
}

func addRepo(args []string) error {
  if len(args)==0 { return argErr("addrepo <url>") }
  url := args[0]

  if os.Geteuid()!=0 { return fmt.Errorf("precisa ser root") }

  if !strings.HasPrefix(url,"http://") &&
     !strings.HasPrefix(url,"https://") &&
     !strings.HasPrefix(url,"file://") {
    return fmt.Errorf("URL inválida: %s", url)
  }

  os.MkdirAll("/etc/xbps.d", 0755)

  h := sha1.Sum([]byte(url))
  fname := fmt.Sprintf("10-repo-%x.conf", h[:3])
  path := filepath.Join("/etc/xbps.d", fname)

  return os.WriteFile(path, []byte("repository="+url+"\n"),0644)
}

func printBannerOLD(w io.Writer) {
  fmt.Fprintln(w, "┌─────────────────── chili-vpm 1.3.0 ───────────────────┐")
  fmt.Fprintln(w, "│ chili-vpm — wrapper estilizado para XBPS (Void Linux) │")
  fmt.Fprintln(w, "│ • Compatível com vpm clássico                         │")
  fmt.Fprintln(w, "└───────────────────────────────────────────────────────┘")
  fmt.Fprintln(w)
}

func printBanner(w io.Writer) {
  top :=  Cyan+Bold+"┌─────────────────── chili-vpm "+version+" ───────────────────┐"+Reset

  mid1 := "│ chili-vpm — "+Red+"wrapper"+Reset+Bold+" estilizado para XBPS (Void Linux) │"+Reset

  mid2 := Bold+"│ "+Green+"•"+Reset+" Compatível com vpm clássico                         │"
  bot  := Cyan+Bold+"└───────────────────────────────────────────────────────┘"+Reset

  fmt.Fprintln(w, top)
  fmt.Fprintln(w, mid1)
  fmt.Fprintln(w, mid2)
  fmt.Fprintln(w, bot)
  fmt.Fprintln(w)
}

// imprime um comando alinhado com largura fixa antes da descrição
// imprime comando alinhado, com comando e argumentos em cores diferentes
func printCmd(cmd string, desc string) {
    const width = 30

    // divide comando em partes
    fields := strings.Fields(cmd)

    var coloredParts []string
    for _, f := range fields {
        if strings.HasPrefix(f, "<") && strings.HasSuffix(f, ">") {
            coloredParts = append(coloredParts, Magenta+f+Reset)
        } else {
            coloredParts = append(coloredParts, Green+f+Reset)
        }
    }

    // remonta tudo já colorido
    coloredCmd := strings.Join(coloredParts, " ")

    // agora alinha usando o texto sem ANSI
    plain := fmt.Sprintf("%-*s", width, cmd)

    // substitui o texto cru pela versão colorida
    padded := strings.Replace(plain, cmd, coloredCmd, 1)

    fmt.Printf("  %s %s%s%s\n", padded, White, desc, Reset)
}

func printHelp() {
    printBanner(os.Stdout)

    fmt.Println(Bold + White + "Uso:" + Reset)
    fmt.Println("  chili-vpm " + Green + "<subcomando>" + Reset + " " + Magenta + "[argumentos]" + Reset)
    fmt.Println()

    // ======================================================
    // REPOSITÓRIOS
    // ======================================================
    fmt.Println(Bold + Cyan + "Repositórios e atualização:" + Reset)
    printCmd("sync",                   "Sincroniza repositórios remotos")
    printCmd("update, up",             "Atualiza o sistema")
    printCmd("listrepos, lr",          "Lista repositórios configurados")
    printCmd("addrepo, ar <url>",      "Adiciona repositório")
    fmt.Println()

    // ======================================================
    // CONSULTA
    // ======================================================
    fmt.Println(Bold + Cyan + "Consulta e listagem:" + Reset)
    printCmd("info <pkg>",             "Mostra informações do pacote")
    printCmd("filelist, fl <pkg>",     "Lista arquivos instalados")
    printCmd("deps <pkg>",             "Mostra dependências")
    printCmd("reverse, rv <pkg>",      "Dependentes reversos")
    printCmd("search, s <nome>",       "Busca pacotes por nome")
    printCmd("searchfile, sf <arq>",   "Busca pacote que contém arquivo")
    printCmd("whatprovides, wp <file>","Mostra quem fornece arquivo")
    printCmd("list, ls",               "Lista pacotes instalados")
    fmt.Println()

    // ======================================================
    // INSTALAÇÃO
    // ======================================================
    fmt.Println(Bold + Cyan + "Instalação e remoção:" + Reset)
    printCmd("install, i <pkg(s)>",    "Instala pacote(s)")
    printCmd("devinstall, di <pkg(s)>","Instala pacote e -devel correspondente")
    printCmd("forceinstall, fi <pkg>", "Instala forçado (ignora conflitos)")
    printCmd("remove <pkg(s)>",        "Remove pacote(s)")
    printCmd("removerecursive <pkg>",  "Remove recursivamente pacote e deps")
    printCmd("autoremove, ar",         "Remove dependências órfãs")
    fmt.Println()

    // ======================================================
    // ALTERNATIVAS
    // ======================================================
    fmt.Println(Bold + Cyan + "Alternativas e reconfigure:" + Reset)
    printCmd("listalternatives, la",   "Lista alternativas")
    printCmd("setalternative, sa <pkg>","Define alternativa")
    printCmd("reconfigure, rc <pkg>",  "Reconfigura pacote")
    fmt.Println()

    // ======================================================
    // SERVIÇOS RUNIT
    // ======================================================
    fmt.Println(Bold + Green + "Serviços (runit):" + Reset)
    printCmd("services, sv, vsv",      "Lista serviços (estilo vsv)")
    printCmd("start, up <svc>",        "Inicia serviço")
    printCmd("stop, down <svc>",       "Para serviço")
    printCmd("restart, rs <svc>",      "Reinicia serviço")
    printCmd("status, st <svc>",       "Status do serviço")
    printCmd("enable, en <svc>",       "Habilita serviço no boot")
    printCmd("disable, dis <svc>",     "Desabilita serviço no boot")
    printCmd("log, svlog <svc> [n]",   "Mostra logs (auto: runit + socklog)")
    fmt.Println()

    // ======================================================
    // LIMPEZA
    // ======================================================
    fmt.Println(Bold + Cyan + "Limpeza:" + Reset)
    printCmd("cleanup, cl",            "Limpa cache do XBPS")
    fmt.Println()

    // ======================================================
    // OUTROS
    // ======================================================
    fmt.Println(Bold + Cyan + "Outros:" + Reset)
    printCmd("help, hp",               "Mostra ajuda")
    printCmd("version",                "Mostra versão")
    fmt.Println()
}

func runVSV() error {
  serviceDir := "/var/service"
  enabledDir := "/etc/runit/runsvdir/default"

  entries, err := os.ReadDir(serviceDir)
  if err != nil {
    return fmt.Errorf("erro lendo %s: %v", serviceDir, err)
  }

  // Cabeçalho (branco)
  fmt.Printf(White+Bold+"   %-20s %-7s %-8s %-8s %-20s %s"+Reset+"\n",
    "SERVICE", "STATE", "ENABLED", "PID", "COMMAND", "TIME")

  for _, e := range entries {
    name := e.Name()
    svc := filepath.Join(serviceDir, name)

    statFile := filepath.Join(svc, "supervise", "stat")
    pidFile  := filepath.Join(svc, "supervise", "pid")

    // ---------- STATE ----------
    state := "down"
    if data, err := os.ReadFile(statFile); err == nil {
      s := strings.TrimSpace(string(data))
      if s != "" {
        state = s
      }
    }

    // ---------- ENABLED ----------
    enabled := false
    if fi, err := os.Lstat(filepath.Join(enabledDir, name)); err == nil &&
      fi.Mode()&os.ModeSymlink != 0 {
      enabled = true
    }

    // ---------- PID ----------
    pid := "-"
    if data, err := os.ReadFile(pidFile); err == nil {
      p := strings.TrimSpace(string(data))
      if p != "" {
        pid = p
      }
    }

    // ---------- COMMAND (IGUAL AO VSV REAL) ----------
    cmd := "-"

    if pid != "-" {
      // 1) /proc/<pid>/comm → nome real do executável
      commPath := "/proc/" + pid + "/comm"
      if data, err := os.ReadFile(commPath); err == nil {
        c := strings.TrimSpace(string(data))
        if c != "" {
          cmd = c
        }
      }

      // 2) título completo /proc/<pid>/cmdline
      cmdlinePath := "/proc/" + pid + "/cmdline"
      if data, err := os.ReadFile(cmdlinePath); err == nil {
        parts := strings.Split(string(data), "\x00")

        if len(parts) > 0 && parts[0] != "" {
          title := parts[0]

          // títulos especiais: "sshd: /usr/bin/sshd -D"
          if strings.Contains(title, ":") {
            cmd = title
          }
        }
      }
    }

    // truncamento igual ao vsv
    if len(cmd) > 18 {
      cmd = cmd[:17] + "…"
    }

    // ---------- TIME ----------
    since := "-"
    if fi, err := os.Stat(pidFile); err == nil {
      dur := time.Since(fi.ModTime())
      switch {
      case dur.Hours() >= 1:
        since = fmt.Sprintf("%d hour", int(dur.Hours()))
      case dur.Minutes() >= 1:
        since = fmt.Sprintf("%d min", int(dur.Minutes()))
      default:
        since = fmt.Sprintf("%d sec", int(dur.Seconds()))
      }
    }

    // ---------- PAD (SEM COR — para alinhar) ----------
    servicePad := fmt.Sprintf("%-20s", name)
    statePad   := fmt.Sprintf("%-7s", state)
    enabledPad := fmt.Sprintf("%-8s", fmt.Sprintf("%v", enabled))
    pidPad     := fmt.Sprintf("%-8s", pid)
    cmdPad     := fmt.Sprintf("%-20s", cmd)
    timePad    := since

    // ---------- CORES ----------
    serviceCol := White + servicePad + Reset

    var stateCol string
    if state == "run" {
      stateCol = Green + statePad + Reset
    } else {
      stateCol = Red + statePad + Reset
    }

    var enabledCol string
    if enabled {
      enabledCol = Green + enabledPad + Reset
    } else {
      enabledCol = Red + enabledPad + Reset
    }

    pidCol := Magenta + pidPad + Reset
    cmdCol := Green + cmdPad + Reset
    timeCol := White + timePad + Reset

    // ✔ ou ✘
    mark := "✘"
    markColor := Red
    if state == "run" {
      mark = "✔"
      markColor = Green
    }

    // ---------- PRINT FINAL ----------
    fmt.Printf(" %s%s%s %s %s %s %s %s %s\n",
      markColor, mark, Reset,
      serviceCol,
      stateCol,
      enabledCol,
      pidCol,
      cmdCol,
      timeCol,
    )
  }

  return nil
}

// execute "sv <cmd> <service>"
func runSVCommand(cmd, service string) error {
  path := "/var/service/" + service
  if _, err := os.Stat(path); err != nil {
    return fmt.Errorf("serviço '%s' não existe em /var/service", service)
  }

  c := exec.Command("sv", cmd, path)
  c.Stdout = os.Stdout
  c.Stderr = os.Stderr
  return c.Run()
}

func svStart(service string) error   { return runSVCommand("up", service) }
func svStop(service string) error    { return runSVCommand("down", service) }
func svRestart(service string) error { return runSVCommand("restart", service) }

func svStatus(service string) error {
    svcPath := "/var/service/" + service
    statFile := filepath.Join(svcPath, "supervise", "stat")
    pidFile  := filepath.Join(svcPath, "supervise", "pid")
    wantFile := filepath.Join(svcPath, "supervise", "want")

    // STATE
    state := "down"
    if data, err := os.ReadFile(statFile); err == nil {
        s := strings.TrimSpace(string(data))
        if s != "" {
            state = s
        }
    }

    // PID
    pid := ""
    if data, err := os.ReadFile(pidFile); err == nil {
        p := strings.TrimSpace(string(data))
        if p != "" {
            pid = p
        }
    }

    // WANT state (optional)
    want := ""
    if data, err := os.ReadFile(wantFile); err == nil {
        w := strings.TrimSpace(string(data))
        if w != "" {
            want = ", want " + w
        }
    }

    // TIME (age of pid)
    since := ""
    if fi, err := os.Stat(pidFile); err == nil {
        dur := time.Since(fi.ModTime())
        if dur.Hours() >= 1 {
            since = fmt.Sprintf("%dh %dm", int(dur.Hours()), int(dur.Minutes())%60)
        } else if dur.Minutes() >= 1 {
            since = fmt.Sprintf("%dm", int(dur.Minutes()))
        } else {
            since = fmt.Sprintf("%ds", int(dur.Seconds()))
        }
    }

    // ------- COLORS -------
    var stateCol string
    if state == "run" {
        stateCol = Green + "run" + Reset
    } else {
        stateCol = Red + "down" + Reset
    }

    svcNameCol := White + service + Reset
    pidCol := ""
    if pid != "" {
        pidCol = fmt.Sprintf("(pid %s)", pid)
    }

    // PRINT EXACT FORMAT OF RUNIT
    if state == "run" {
        fmt.Printf("%s: %s: %s %s%s\n",
            stateCol,
            svcNameCol,
            pidCol,
            since,
            want,
        )
    } else {
        fmt.Printf("%s: %s: %s%s\n",
            stateCol,
            svcNameCol,
            since,
            want,
        )
    }

    return nil
}

func svEnable(service string) error {
  src := "/var/service/" + service
  dst := "/etc/runit/runsvdir/default/" + service
  return os.Symlink(src, dst)
}

func svDisable(service string) error {
  dst := "/etc/runit/runsvdir/default/" + service
  return os.Remove(dst)
}

func decodeTAI64N(line []byte) (time.Time, []byte, error) {
    // TAI64N timestamps always begin with "@40000000"
    if len(line) < 25 || line[0] != '@' {
        return time.Time{}, line, fmt.Errorf("not tai64n")
    }

    hexTime := string(line[1:25]) // "40000000xxxxxxxxxxxxxxxx"
    secHex := hexTime[8:24]       // last 16 characters = seconds

    sec, err := strconv.ParseInt(secHex, 16, 64)
    if err != nil {
        return time.Time{}, line, err
    }

    // base epoch correction
    // TAI64N epoch (1970) = UNIX epoch + 10s
    unix := sec - 10

    msg := bytes.TrimSpace(line[25:])
    return time.Unix(unix, 0), msg, nil
}

func colorizeLogLine(line string) string {
    lower := strings.ToLower(line)

    // ---- ERROS ----
    if strings.Contains(lower, "error") ||
       strings.Contains(lower, "err:") ||
       strings.Contains(lower, "err ") ||
       strings.Contains(lower, "fatal") ||
       strings.Contains(lower, "failed") ||
       strings.Contains(lower, "authentication failure") ||
       strings.Contains(lower, "invalid user") ||
       strings.Contains(lower, "failed password") {
        return Red + line + Reset
    }

    // ---- WARNING ----
    if strings.Contains(lower, "warning") ||
       strings.Contains(lower, "warn:") ||
       strings.Contains(lower, "warn ") ||
       strings.Contains(lower, "deprecated") {
        return Yellow + line + Reset
    }

    // ---- INFO ----
    if strings.Contains(lower, "info") ||
       strings.HasPrefix(lower, "accepted") ||
       strings.Contains(lower, "session opened") ||
       strings.Contains(lower, "listening on") {
        return Green + line + Reset
    }

    // ---- DEBUG ----
    if strings.Contains(lower, "debug") ||
       strings.Contains(lower, "trace") {
        return Blue + line + Reset
    }

    // ---- DEFAULT ----
    return White + line + Reset
}

func svLogTailRunit(service string, nlines int) error {
    logDir := "/var/service/" + service + "/log/main"

    entries, err := os.ReadDir(logDir)
    if err != nil {
        return fmt.Errorf("log não encontrado em %s", logDir)
    }

    // juntar todos os logs rotacionados
    var files []string
    for _, e := range entries {
        if e.Name() == "current" || strings.HasPrefix(e.Name(), "@4000000") {
            files = append(files, filepath.Join(logDir, e.Name()))
        }
    }

    if len(files) == 0 {
        return fmt.Errorf("nenhum log encontrado")
    }

    // ordenar (runit mantém ordem alfabética cronológica)
    sort.Strings(files)

    // ler tudo e juntar em memória
    var lines []string
    for _, f := range files {
        data, err := os.ReadFile(f)
        if err != nil { continue }

        parts := bytes.Split(data, []byte("\n"))
        for _, p := range parts {
            if len(p) == 0 { continue }
            lines = append(lines, string(p))
        }
    }

    // pegar últimas N linhas
    total := len(lines)
    start := total - nlines
    if start < 0 { start = 0 }

    for _, l := range lines[start:] {
        b := []byte(l)
        ts, msg, err := decodeTAI64N(b)
        if err != nil {
            fmt.Println(White + l + Reset)
            continue
        }

        // colorido: timestamp em magenta, msg em branco
        fmt.Println(colorizeLogLine(fmt.Sprintf("%s %s", ts.Format("2006-01-02 15:04:05"), msg)))
    }

    return nil
}

func svLogTailAuto(service string, nlines int) error {

    // 1) tentar runit-log
    logDir := "/var/service/" + service + "/log/main"
    if _, err := os.Stat(logDir); err == nil {
        return svLogTailRunit(service, nlines)
    }

    // 2) tentar socklog-unix
    if _, err := os.Stat("/var/log/socklog"); err == nil {
        if err2 := svLogTailSocklog(service, nlines); err2 == nil {
            return nil
        }
    }

    return fmt.Errorf("nenhuma fonte de log encontrada para '%s'", service)
}

func svLogTailSocklog(service string, nlines int) error {
    base := "/var/log/socklog"

    // primeiro tenta categorias mais prováveis
    likely := []string{
        "auth", "daemon", "messages", "user", "cron",
    }

    // 1) tentar arquivos por nome do serviço dentro das categorias
    for _, cat := range likely {
        path := filepath.Join(base, cat, service)
        if _, err := os.Stat(path); err == nil {
            return tailFile(service, path, nlines)
        }
    }

    // 2) tentar /var/log/socklog/<cat>/current
    for _, cat := range likely {
        path := filepath.Join(base, cat, "current")
        if _, err := os.Stat(path); err == nil {
            return tailFile(service, path, nlines)
        }
    }

    // 3) procurar em TUDO que o socklog tiver
    filepath.Walk(base, func(path string, info os.FileInfo, err error) error {
        if err == nil && !info.IsDir() {
            if strings.Contains(strings.ToLower(path), service) ||
               strings.Contains(strings.ToLower(info.Name()), service) {
                // achou arquivo associado ao serviço
                tailFile(service, path, nlines)
            }
        }
        return nil
    })

    return fmt.Errorf("não encontrado no socklog para '%s'", service)
}

func tailFile(service, path string, nlines int) error {
    data, err := os.ReadFile(path)
    if err != nil {
        return err
    }

    lines := strings.Split(string(data), "\n")
    start := len(lines) - nlines
    if start < 0 {
        start = 0
    }

    for _, l := range lines[start:] {
        if len(strings.TrimSpace(l)) == 0 {
            continue
        }

        if logLineMatchesService(service, l) {
            fmt.Println(colorizeLogLine(l))
        }
    }

    return nil
}

func logLineMatchesService(service, line string) bool {
    lower := strings.ToLower(line)
    s := strings.ToLower(service)

    // Caso mais comum: nome direto
    if strings.Contains(lower, s) {
        return true
    }

    // sshd tem mensagens PAM
    if s == "sshd" {
        if strings.Contains(lower, "pam_unix(sshd") ||
           strings.Contains(lower, "sshd:") ||
           strings.Contains(lower, "ssh") {
            return true
        }
    }

    // dhcpcd
    if s == "dhcpcd" {
        if strings.Contains(lower, "dhcpcd") ||
           strings.Contains(lower, "dhcp") {
            return true
        }
    }

    // udevd
    if s == "udevd" {
        if strings.Contains(lower, "udevd") ||
           strings.Contains(lower, "udev") {
            return true
        }
    }

    // NetworkManager
    if s == "networkmanager" {
        if strings.Contains(lower, "networkmanager") ||
           strings.Contains(lower, "nm-") {
            return true
        }
    }

    // generic: prefixos syslog
    parts := strings.Fields(lower)
    if len(parts) > 1 {
        if parts[1] == s || strings.Contains(parts[1], s) {
            return true
        }
    }

    return false
}
