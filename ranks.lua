#include "main.lua"

Hook_AddListener("TDMP_ChatAdminInit", "TDMP_ChatAdminInitRank", function()
    TDMP_AddRank("superadmin", { -- 0 equals most privilege
        privilege = 0
    })
    TDMP_AddRank("admin", {
        privilege = 5
    })
    TDMP_AddRank("moderator", {
        privilege = 10
    })
    TDMP_AddRank("user", {
        privilege = 100
    })
end)