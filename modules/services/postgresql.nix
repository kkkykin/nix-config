# 各服务模块自行追加 ensureDatabases / ensureUsers / authentication
{...}: {
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    extensions = ps: [ps.plpython3];
  };
}
