Config = {}
Config.zStart = 2200 --12:00
Config.zEnd = 0800 --05:00
Config.takeTime = 600000 --bölgeyi eli geçirme süresi 600000 = 10 dakika (ms)
Config.updateZoneCaseTime = 3 --bölge kasasnıdaki para ne kadar sürede bir artıcak (second)
Config.updateZoneCaseAmount = 1500 --bölge kasasnıdaki para ne kadar artıcak (ms)
Config.playerNeeded = 1 --bölgeyi eli geçirmek için gereken oyuncu sayısı
Config.WhiteJobs = {
    "police",
    "ambulance"
}
Config.JobColours = {
    ["police"] = {colour = 38, title = "Police Zone"},
    ["ambulance"] = {colour = 27, title = "Ambulance Zone"},
}
Config.Zones = {
    {
        Poly = {
            {
                center = vector3(500.0, 500.0, 500.0),
                lenght = 30.0,
                width = 50.0,
                rotation = 90,
                name = "box_zone3",
                debugPoly = false
            },
            {
                center = vector3(600.0, 600.0, 600.0),
                lenght = 30.0,
                width = 50.0,
                rotation = 90,
                name = "box_zone4",
                debugPoly = false
            }
        },
        radiusColour = 1,
        Biliptitle = "A",
    },
    {
        Poly = {
            {
                center = vector3(0.0, 0.0, 0.0),
                lenght = 30.0,
                width = 50.0,
                rotation = 90,
                name = "box_zone",
                debugPoly = false
            },
            {
                center = vector3(100.0, 100.0, 100.0),
                lenght = 30.0,
                width = 50.0,
                rotation = 90,
                name = "box_zone2",
                debugPoly = false
            }
        },
        radiusColour = 1,
        Biliptitle = "B",
    },
}