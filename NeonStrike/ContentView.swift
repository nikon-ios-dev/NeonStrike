import SwiftUI
import UIKit
import AVFoundation
import AudioToolbox

// MARK: - Звуковой движок (только вибрация)
class SoundManager {
    static let shared = SoundManager()
    private init() {}
    
    func playShoot(type: WeaponType) {
        let generator = UIImpactFeedbackGenerator(style: type == .laser ? .rigid : .light)
        generator.impactOccurred()
    }
    
    func playExplosion() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    func playCombo() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

// MARK: - Модели
enum WeaponType: String, CaseIterable {
    case standard = "Стандарт", shotgun = "Дробовик", laser = "Лазер", homing = "Самонаведение"
    var fireRate: TimeInterval {
        switch self {
        case .standard: return 0.18
        case .shotgun: return 0.45
        case .laser: return 0.12
        case .homing: return 0.35
        }
    }
}

struct ShopSkin: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let color: Color
    let price: Int
    static let all: [ShopSkin] = [
        ShopSkin(name: "Неон", color: .cyan, price: 0),
        ShopSkin(name: "Золото", color: .yellow, price: 500),
        ShopSkin(name: "Багровый", color: .red, price: 500),
        ShopSkin(name: "Изумруд", color: .green, price: 1000),
        ShopSkin(name: "Фиолет", color: .purple, price: 1500),
        ShopSkin(name: "Платина", color: .white, price: 3000)
    ]
    func hash(into hasher: inout Hasher) { hasher.combine(name) }
    static func == (lhs: ShopSkin, rhs: ShopSkin) -> Bool { lhs.name == rhs.name }
}

struct DailyQuest: Identifiable, Codable {
    let id: String
    let title: String
    let target: Int
    let reward: Int
    var progress: Int
    var completed: Bool
    
    static func generateNew() -> [DailyQuest] {
        let templates = [
            ("Уничтожь 50 врагов", 50, 100),
            ("Набери 500 очков", 500, 150),
            ("Победи 1 босса", 1, 200),
            ("Собери 10 бонусов", 10, 80),
            ("Сыграй 3 игры", 3, 120)
        ]
        return templates.shuffled().prefix(3).map {
            DailyQuest(id: UUID().uuidString, title: $0.0, target: $0.1, reward: $0.2, progress: 0, completed: false)
        }
    }
}

enum EnemyType { case scout, fighter, tank }
enum PowerUpType { case health, weapon, bomb }

enum ShipSkin: String, CaseIterable {
    case cyan = "Неон", gold = "Золото", crimson = "Багровый"
    var color: Color {
        switch self {
        case .cyan: return .cyan
        case .gold: return .yellow
        case .crimson: return .red
        }
    }
}

enum BossType {
    case tank, speedster, teleporter, splitter, shield, summoner
    var color: Color {
        switch self {
        case .tank: return .red
        case .speedster: return .orange
        case .teleporter: return .purple
        case .splitter: return .pink
        case .shield: return .blue
        case .summoner: return .green
        }
    }
    var maxHP: Int {
        switch self {
        case .tank: return 80
        case .speedster: return 50
        case .teleporter: return 60
        case .splitter: return 70
        case .shield: return 100
        case .summoner: return 65
        }
    }
    var name: String {
        switch self {
        case .tank: return "ТАНК"
        case .speedster: return "СКОРОСТНОЙ"
        case .teleporter: return "ТЕЛЕПОРТЕР"
        case .splitter: return "РАЗДЕЛИТЕЛЬ"
        case .shield: return "ЩИТ"
        case .summoner: return "ПРИЗЫВАТЕЛЬ"
        }
    }
}

enum UpgradeType: String, CaseIterable {
    case damage = "Урон +20%"
    case maxHP = "Здоровье +25"
    case doubleShot = "Двойные пули"
    case slowTime = "Замедление времени"
    case fireRate = "Скорость стрельбы +15%"
    case magnet = "Магнит бонусов"
    
    var icon: String {
        switch self {
        case .damage: return "flame.fill"
        case .maxHP: return "heart.fill"
        case .doubleShot: return "arrow.up.forward.square.fill"
        case .slowTime: return "hourglass"
        case .fireRate: return "bolt.fill"
        case .magnet: return "arrow.down.circle.fill"
        }
    }
    var description: String {
        switch self {
        case .damage: return "Все пули наносят на 20% больше урона"
        case .maxHP: return "Максимальное здоровье увеличено на 25"
        case .doubleShot: return "Каждый выстрел создаёт 2 пули"
        case .slowTime: return "Враги движутся медленнее 10 секунд"
        case .fireRate: return "Оружие стреляет на 15% быстрее"
        case .magnet: return "Бонусы притягиваются к игроку"
        }
    }
}

struct Boss: Identifiable {
    let id = UUID()
    var position: CGPoint
    var type: BossType
    var hp: Int
    var maxHP: Int
    var lastAttack: Date = .distantPast
    var attackPattern: Int = 0
    var teleportTimer: Date = .now
}

struct Bullet: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGVector
    var isEnemy: Bool
    var damage: Int = 1
    var weaponType: WeaponType = .standard
    var hitEnemies: Set<UUID> = []
}

struct Enemy: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGVector
    var type: EnemyType
    var hp: Int
    var lastShot: Date = .distantPast
}

struct PowerUp: Identifiable {
    let id = UUID()
    var position: CGPoint
    var type: PowerUpType
}

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGVector
    var life: Double
    var maxLife: Double
    var color: Color
    var size: CGFloat
}

struct Star: Identifiable {
    let id = UUID()
    var position: CGPoint
    var speed: CGFloat
    var size: CGFloat
    var brightness: Double
}

struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
}

let allAchievements: [Achievement] = [
    Achievement(id: "first_blood", title: "Первая кровь", description: "Набери 50 очков", icon: "target"),
    Achievement(id: "survivor", title: "Выживший", description: "Набери 200 очков", icon: "shield"),
    Achievement(id: "legend", title: "Легенда", description: "Набери 500 очков", icon: "crown"),
    Achievement(id: "veteran", title: "Ветеран", description: "Сыграй 10 игр", icon: "gamecontroller"),
    Achievement(id: "boss_slayer", title: "Убийца боссов", description: "Победи 3 боссов", icon: "flame.fill")
]

struct AchievementPopup: Identifiable {
    let id = UUID()
    let achievement: Achievement
}

// MARK: - Менеджер сохранений
class SaveManager {
    static let shared = SaveManager()
    private let defaults = UserDefaults.standard
    
    var highScore: Int {
        get { defaults.integer(forKey: "highScore") }
        set { defaults.set(newValue, forKey: "highScore") }
    }
    var gamesPlayed: Int {
        get { defaults.integer(forKey: "gamesPlayed") }
        set { defaults.set(newValue, forKey: "gamesPlayed") }
    }
    var bossesDefeated: Int {
        get { defaults.integer(forKey: "bossesDefeated") }
        set { defaults.set(newValue, forKey: "bossesDefeated") }
    }
    var crystals: Int {
        get { defaults.integer(forKey: "crystals") }
        set { defaults.set(newValue, forKey: "crystals") }
    }
    var purchasedSkins: Set<String> {
        get {
            let arr = defaults.array(forKey: "purchasedSkins") as? [String] ?? ["Неон"]
            return Set(arr)
        }
        set { defaults.set(Array(newValue), forKey: "purchasedSkins") }
    }
    var lastDailyReward: Date {
        get {
            let time = defaults.double(forKey: "lastDailyReward")
            return time > 0 ? Date(timeIntervalSince1970: time) : Date.distantPast
        }
        set { defaults.set(newValue.timeIntervalSince1970, forKey: "lastDailyReward") }
    }
    var currentSkinRaw: String {
        get { defaults.string(forKey: "currentSkin") ?? "Неон" }
        set { defaults.set(newValue, forKey: "currentSkin") }
    }
    var unlockedAchievements: Set<String> {
        get {
            let arr = defaults.array(forKey: "achievements") as? [String] ?? []
            return Set(arr)
        }
        set { defaults.set(Array(newValue), forKey: "achievements") }
    }
    var dailyQuests: [DailyQuest] {
        get {
            if let data = defaults.data(forKey: "dailyQuests") {
                return (try? JSONDecoder().decode([DailyQuest].self, from: data)) ?? DailyQuest.generateNew()
            }
            return DailyQuest.generateNew()
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: "dailyQuests")
            }
        }
    }
    var dailyQuestDate: String {
        get { defaults.string(forKey: "dailyQuestDate") ?? "" }
        set { defaults.set(newValue, forKey: "dailyQuestDate") }
    }
    
    func unlockAchievement(_ id: String) -> Bool {
        var set = unlockedAchievements
        if set.contains(id) { return false }
        set.insert(id)
        unlockedAchievements = set
        return true
    }
    func buySkin(_ skin: ShopSkin) -> Bool {
        guard crystals >= skin.price else { return false }
        crystals -= skin.price
        var purchased = purchasedSkins
        purchased.insert(skin.name)
        purchasedSkins = purchased
        return true
    }
}

// MARK: - Игровой движок
@Observable
class GameEngine {
    var playerPos: CGPoint = .zero
    var playerHP: Int = 100
    var maxHP: Int = 100
    var currentWeapon: WeaponType = .standard
    var currentSkin: ShipSkin = .cyan {
        didSet { SaveManager.shared.currentSkinRaw = currentSkin.rawValue }
    }
    var bullets: [Bullet] = []
    var enemies: [Enemy] = []
    var powerUps: [PowerUp] = []
    var particles: [Particle] = []
    var stars: [Star] = []
    var boss: Boss? = nil
    var score: Int = 0
    var wave: Int = 1
    var isGameOver: Bool = false
    var isPlaying: Bool = false
    var isPaused: Bool = false
    var shakeAmount: CGFloat = 0
    var canRevive: Bool = true
    var highScore: Int = SaveManager.shared.highScore
    var isNewRecord: Bool = false
    var crystalsEarned: Int = 0
    var unlockedAchievements: Set<String> = SaveManager.shared.unlockedAchievements
    var activePopup: AchievementPopup?
    var enemiesKilled: Int = 0
    var powerUpsCollected: Int = 0
    var bossesKilled: Int = 0
    var joystickVector: CGVector = .zero
    var bombs: Int = 1
    var bombFlashOpacity: Double = 0
    var isBombActive: Bool = false
    var comboCount: Int = 0
    var comboMultiplier: Int = 1
    var lastKillTime: Date = .distantPast
    var comboDisplayOpacity: Double = 0
    var comboScale: CGFloat = 1.0
    private var lastUpdate: Date = .now
    private var lastShot: Date = .now
    private var lastSpawn: Date = .now
    private var waveTimer: Double = 0
    
    var damageMultiplier: Double = 1.0
    var fireRateMultiplier: Double = 1.0
    var isDoubleShot: Bool = false
    var isSlowTime: Bool = false
    var slowTimeEnd: Date = .distantPast
    var isMagnet: Bool = false
    var waveCompleted: Bool = false
    var pendingUpgrades: [UpgradeType] = []
    var showUpgradeChoice: Bool = false
    var showWaveComplete: Bool = false
    var shieldGunsDestroyed: Int = 0
    var totalShieldGuns: Int = 4
    
    init() {
        if let skin = ShipSkin(rawValue: SaveManager.shared.currentSkinRaw) {
            currentSkin = skin
        }
    }
    
    func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func start(size: CGSize, isRevive: Bool = false) {
        if !isRevive {
            playerPos = CGPoint(x: size.width / 2, y: size.height - 150)
            playerHP = maxHP
            currentWeapon = .standard
            score = 0
            wave = 1
            canRevive = true
            isNewRecord = false
            crystalsEarned = 0
            enemiesKilled = 0
            powerUpsCollected = 0
            bossesKilled = 0
            bombs = 1
            bombFlashOpacity = 0
            isBombActive = false
            comboCount = 0
            comboMultiplier = 1
            lastKillTime = .distantPast
            comboDisplayOpacity = 0
            comboScale = 1.0
            damageMultiplier = 1.0
            fireRateMultiplier = 1.0
            isDoubleShot = false
            isSlowTime = false
            isMagnet = false
            showUpgradeChoice = false
            showWaveComplete = false
            pendingUpgrades = []
        } else {
            playerHP = maxHP / 2
            currentWeapon = .standard
            canRevive = false
            enemies.removeAll { hypot($0.position.x - playerPos.x, $0.position.y - playerPos.y) < 150 }
            bullets.removeAll { $0.isEnemy }
            boss = nil
        }
        isGameOver = false
        isPlaying = true
        isPaused = false
        shakeAmount = 0
        lastUpdate = .now
        lastShot = .now
        lastSpawn = .now
        waveTimer = 0
        
        if stars.isEmpty {
            let newStars: [Star] = (0..<80).map { _ in
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let speed = CGFloat.random(in: 20...80)
                let sz = CGFloat.random(in: 1...2.5)
                let brightness = Double.random(in: 0.3...1.0)
                return Star(position: CGPoint(x: x, y: y), speed: speed, size: sz, brightness: brightness)
            }
            stars = newStars
        }
    }
    
    func togglePause() {
        isPaused.toggle()
        if isPaused { triggerHaptic(.light) }
    }
    
    func exitToMenu() {
        isPlaying = false
        isPaused = false
        isGameOver = false
    }
    
    func checkAchievements() {
        if score >= 50 && unlockedAchievements.insert("first_blood").inserted { showAchievementPopup(id: "first_blood") }
        if score >= 200 && unlockedAchievements.insert("survivor").inserted { showAchievementPopup(id: "survivor") }
        if score >= 500 && unlockedAchievements.insert("legend").inserted { showAchievementPopup(id: "legend") }
        let bosses = SaveManager.shared.bossesDefeated
        if bosses >= 3 && unlockedAchievements.insert("boss_slayer").inserted { showAchievementPopup(id: "boss_slayer") }
    }
    
    private func showAchievementPopup(id: String) {
        _ = SaveManager.shared.unlockAchievement(id)
        if let ach = allAchievements.first(where: { $0.id == id }) {
            activePopup = AchievementPopup(achievement: ach)
            triggerHaptic(.heavy)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { self.activePopup = nil }
        }
    }
    
    func spawnBoss(size: CGSize) {
        let types: [BossType] = [.tank, .speedster, .teleporter, .splitter, .shield, .summoner]
        let type = types[wave / 5 % types.count]
        let hp = type.maxHP / 2 + (wave / 5) * 5
        boss = Boss(position: CGPoint(x: size.width / 2, y: -80), type: type, hp: hp, maxHP: hp)
        shieldGunsDestroyed = 0
        triggerHaptic(.heavy)
        shakeAmount = 20
    }
    
    func updateCombo(now: Date) {
        if comboCount > 0 && now.timeIntervalSince(lastKillTime) > 3.0 {
            withAnimation(.easeOut(duration: 0.3)) { comboDisplayOpacity = 0 }
            comboCount = 0
            comboMultiplier = 1
        }
    }
    
    func addScore(_ base: Int) {
        score += base * comboMultiplier
    }
    
    func incrementCombo(now: Date) {
        comboCount += 1
        lastKillTime = now
        if comboCount >= 30 { comboMultiplier = 10 }
        else if comboCount >= 20 { comboMultiplier = 5 }
        else if comboCount >= 10 { comboMultiplier = 3 }
        else if comboCount >= 5 { comboMultiplier = 2 }
        else { comboMultiplier = 1 }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            comboDisplayOpacity = 1.0
            comboScale = 1.3
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.2)) { self.comboScale = 1.0 }
        }
        if comboMultiplier >= 3 { SoundManager.shared.playCombo() }
    }
    
    func resetCombo() {
        if comboCount > 0 {
            withAnimation(.easeOut(duration: 0.3)) { comboDisplayOpacity = 0 }
            comboCount = 0
            comboMultiplier = 1
        }
    }
    
    func useBomb() {
        guard bombs > 0 && !isBombActive else { return }
        bombs -= 1
        isBombActive = true
        bombFlashOpacity = 1.0
        
        isSlowTime = true
        slowTimeEnd = Date.now.addingTimeInterval(10)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.isSlowTime = false
        }
        
        for e in enemies {
            addScore(enemyScore(e.type))
            spawnExplosion(at: e.position, type: e.type)
        }
        enemies.removeAll()
        bullets.removeAll { $0.isEnemy }
        
        if var b = boss {
            b.hp -= 40
            spawnHitParticles(at: b.position, color: b.type.color, count: 40)
            if b.hp <= 0 {
                addScore(200 + wave * 10)
                bossesKilled += 1
                spawnExplosion(at: b.position, type: .tank)
                spawnExplosion(at: b.position, type: .fighter)
                spawnExplosion(at: b.position, type: .scout)
                SoundManager.shared.playExplosion()
                shakeAmount = 25
                triggerHaptic(.heavy)
                crystalsEarned += 10
                powerUps.append(PowerUp(position: b.position, type: .health))
                powerUps.append(PowerUp(position: b.position, type: .weapon))
                SaveManager.shared.bossesDefeated += 1
                checkAchievements()
                boss = nil
                wave += 1
                waveTimer = 0
            } else { boss = b }
        }
        shakeAmount = 35
        triggerHaptic(.heavy)
        SoundManager.shared.playExplosion()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { withAnimation(.easeOut(duration: 0.7)) { self.bombFlashOpacity = 0 } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { self.isBombActive = false }
    }
    
    func applyUpgrade(_ upgrade: UpgradeType) {
        switch upgrade {
        case .damage: damageMultiplier *= 1.2
        case .maxHP: maxHP += 25; playerHP = min(playerHP + 25, maxHP)
        case .doubleShot: isDoubleShot = true
        case .slowTime: isSlowTime = true; slowTimeEnd = Date.now.addingTimeInterval(10)
        case .fireRate: fireRateMultiplier *= 1.15
        case .magnet: isMagnet = true
        }
        showUpgradeChoice = false
        isPaused = false
    }
    
    func update(now: Date, size: CGSize) {
        guard isPlaying && !isGameOver && !isPaused else { return }
        let dt = min(now.timeIntervalSince(lastUpdate), 0.05)
        lastUpdate = now
        
        let timeScale: CGFloat = (isSlowTime && now < slowTimeEnd) ? 0.5 : 1.0
        
        shakeAmount *= 0.85
        if shakeAmount < 0.1 { shakeAmount = 0 }
        
        updateCombo(now: now)
        
        let speed: CGFloat = 320
        playerPos.x += joystickVector.dx * speed * dt
        playerPos.y += joystickVector.dy * speed * dt
        playerPos.x = max(25, min(size.width - 25, playerPos.x))
        playerPos.y = max(size.height * 0.4, min(size.height - 50, playerPos.y))
        
        if now.timeIntervalSince(lastShot) > currentWeapon.fireRate / fireRateMultiplier { shoot(); lastShot = now }
        if boss == nil && wave % 5 == 0 && waveTimer > 2 { spawnBoss(size: size); waveTimer = 0 }
        let spawnInterval = max(0.5, 1.2 - Double(wave) * 0.08)
        if now.timeIntervalSince(lastSpawn) > spawnInterval && boss == nil { spawnEnemy(size: size); lastSpawn = now }
        waveTimer += dt
        if waveTimer > 20 && boss == nil { wave += 1; waveTimer = 0 }
        
        for i in stars.indices {
            stars[i].position.y += stars[i].speed * dt
            if stars[i].position.y > size.height { stars[i].position.y = 0; stars[i].position.x = .random(in: 0...size.width) }
        }
        for i in bullets.indices {
            bullets[i].position.x += bullets[i].velocity.dx * dt
            bullets[i].position.y += bullets[i].velocity.dy * dt
        }
        bullets.removeAll { $0.position.y < -20 || $0.position.y > size.height + 20 || $0.position.x < -20 || $0.position.x > size.width + 20 }
        
        if var b = boss {
            if b.position.y < 100 { b.position.y += 50 * dt }
            else { b.position.x += sin(now.timeIntervalSinceReferenceDate * 0.5) * 100 * dt }
            if b.type == .teleporter && now.timeIntervalSince(b.teleportTimer) > 3 {
                b.position.x = .random(in: 60...(size.width - 60))
                b.teleportTimer = now
                spawnHitParticles(at: b.position, color: .purple, count: 20)
            }
            let attackInterval: TimeInterval = b.type == .speedster ? 4.0 : 6.0
            if now.timeIntervalSince(b.lastAttack) > attackInterval { bossAttack(size: size) }
            boss = b
        }
        
        for i in enemies.indices {
            enemies[i].position.x += enemies[i].velocity.dx * dt * timeScale
            enemies[i].position.y += enemies[i].velocity.dy * dt * timeScale
            if enemies[i].type == .fighter && now.timeIntervalSince(enemies[i].lastShot) > 1.5 {
                let dx = playerPos.x - enemies[i].position.x
                let dy = playerPos.y - enemies[i].position.y
                let len = max(hypot(dx, dy), 1)
                bullets.append(Bullet(position: enemies[i].position, velocity: CGVector(dx: dx/len * 280, dy: dy/len * 280), isEnemy: true))
                enemies[i].lastShot = now
            }
        }
        enemies.removeAll { $0.position.y > size.height + 50 || $0.hp <= 0 }
        
        for i in powerUps.indices {
            powerUps[i].position.y += 80 * dt * timeScale
            
            if isMagnet {
                let dx = playerPos.x - powerUps[i].position.x
                let dy = playerPos.y - powerUps[i].position.y
                let dist = hypot(dx, dy)
                if dist < 150 {
                    powerUps[i].position.x += dx / dist * 200 * dt
                    powerUps[i].position.y += dy / dist * 200 * dt
                }
            }
        }
        powerUps.removeAll { $0.position.y > size.height + 30 }
        
        for i in particles.indices {
            particles[i].position.x += particles[i].velocity.dx * dt
            particles[i].position.y += particles[i].velocity.dy * dt
            particles[i].velocity.dx *= 0.96
            particles[i].velocity.dy *= 0.96
            particles[i].life -= dt
        }
        particles.removeAll { $0.life <= 0 }
        
        for i in bullets.indices where !bullets[i].isEnemy {
            for ei in enemies.indices {
                let b = bullets[i], e = enemies[ei]
                if hypot(b.position.x - e.position.x, b.position.y - e.position.y) < 25 {
                    if b.weaponType == .laser || b.weaponType == .homing {
                        guard !bullets[i].hitEnemies.contains(e.id) else { break }
                        bullets[i].hitEnemies.insert(e.id)
                    }
                    enemies[ei].hp -= b.damage
                    spawnHitParticles(at: e.position, color: .pink, count: 4)
                    if b.weaponType != .laser { bullets[i].position.y = -999 }
                    if enemies[ei].hp <= 0 {
                        addScore(enemyScore(e.type))
                        enemiesKilled += 1
                        incrementCombo(now: now)
                        spawnExplosion(at: e.position, type: e.type)
                        SoundManager.shared.playExplosion()
                        checkAchievements()
                        if Double.random(in: 0...1) < 0.1 { crystalsEarned += 1; spawnHitParticles(at: e.position, color: .cyan, count: 8) }
                        if Double.random(in: 0...1) < 0.15 {
                            let rand = Double.random(in: 0...1)
                            let type: PowerUpType = rand < 0.15 ? .bomb : (rand < 0.55 ? .health : .weapon)
                            powerUps.append(PowerUp(position: e.position, type: type))
                        }
                    }
                    break
                }
            }
            if var b = boss {
                let dist = hypot(bullets[i].position.x - b.position.x, bullets[i].position.y - b.position.y)
                if dist < 50 {
                    if b.type == .shield && shieldGunsDestroyed < totalShieldGuns && Double.random(in: 0...1) < 0.3 {
                        shieldGunsDestroyed += 1
                        spawnHitParticles(at: b.position, color: .blue, count: 10)
                    }
                    
                    if bullets[i].weaponType == .laser || bullets[i].weaponType == .homing {
                        guard !bullets[i].hitEnemies.contains(b.id) else { break }
                        bullets[i].hitEnemies.insert(b.id)
                    }
                    b.hp -= bullets[i].damage
                    spawnHitParticles(at: bullets[i].position, color: b.type.color, count: 6)
                    if bullets[i].weaponType != .laser { bullets[i].position.y = -999 }
                    if b.hp <= 0 {
                        addScore(200 + wave * 10)
                        bossesKilled += 1
                        spawnExplosion(at: b.position, type: .tank)
                        spawnExplosion(at: b.position, type: .fighter)
                        spawnExplosion(at: b.position, type: .scout)
                        SoundManager.shared.playExplosion()
                        shakeAmount = 25
                        triggerHaptic(.heavy)
                        crystalsEarned += 10
                        powerUps.append(PowerUp(position: b.position, type: .health))
                        powerUps.append(PowerUp(position: b.position, type: .weapon))
                        SaveManager.shared.bossesDefeated += 1
                        checkAchievements()
                        
                        if b.type == .splitter {
                            for i in -1...1 {
                                enemies.append(Enemy(position: CGPoint(x: b.position.x + CGFloat(i) * 60, y: b.position.y), velocity: CGVector(dx: 0, dy: 80), type: .tank, hp: 3))
                            }
                            spawnExplosion(at: b.position, type: .tank)
                        }
                        
                        boss = nil
                        wave += 1
                        waveTimer = 0
                        waveCompleted = true
                        
                        pendingUpgrades = Array(UpgradeType.allCases.shuffled().prefix(3))
                        showUpgradeChoice = true
                        showWaveComplete = true
                        isPaused = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.showWaveComplete = false
                        }
                    } else { boss = b }
                }
            }
        }
        bullets.removeAll { $0.position.y < -500 }
        
        for i in bullets.indices where bullets[i].weaponType == .homing && !bullets[i].isEnemy {
            var nearestEnemy: Enemy?; var minDist: CGFloat = 350
            for e in enemies {
                let dist = hypot(bullets[i].position.x - e.position.x, bullets[i].position.y - e.position.y)
                if dist < minDist { minDist = dist; nearestEnemy = e }
            }
            if let target = nearestEnemy {
                let dx = target.position.x - bullets[i].position.x
                let dy = target.position.y - bullets[i].position.y
                let len = max(hypot(dx, dy), 1)
                let targetVx = (dx / len) * 500, targetVy = (dy / len) * 500
                bullets[i].velocity.dx += (targetVx - bullets[i].velocity.dx) * 0.15
                bullets[i].velocity.dy += (targetVy - bullets[i].velocity.dy) * 0.15
            }
        }
        
        for bi in bullets.indices where bullets[bi].isEnemy {
            if hypot(bullets[bi].position.x - playerPos.x, bullets[bi].position.y - playerPos.y) < 22 {
                takeDamage(1)
                resetCombo()
                bullets[bi].position.y = 9999
            }
        }
        for ei in enemies.indices {
            if hypot(enemies[ei].position.x - playerPos.x, enemies[ei].position.y - playerPos.y) < 35 {
                takeDamage(8)
                resetCombo()
                enemies[ei].hp = 0
                spawnExplosion(at: enemies[ei].position, type: enemies[ei].type)
            }
        }
        
        for pui in powerUps.indices {
            if hypot(powerUps[pui].position.x - playerPos.x, powerUps[pui].position.y - playerPos.y) < 30 {
                if powerUps[pui].type == .health { playerHP = min(maxHP, playerHP + 80); triggerHaptic(.light) }
                else if powerUps[pui].type == .weapon { currentWeapon = [.shotgun, .laser, .homing].randomElement() ?? .standard; triggerHaptic(.medium) }
                else if powerUps[pui].type == .bomb { bombs += 1; triggerHaptic(.heavy) }
                powerUpsCollected += 1
                spawnHitParticles(at: powerUps[pui].position, color: .green, count: 15)
                powerUps[pui].position.y = 9999
            }
        }
        powerUps.removeAll { $0.position.y > 5000 }
    }
    
    private func bossAttack(size: CGSize) {
        guard var b = boss else { return }
        b.attackPattern = (b.attackPattern + 1) % 4
        
        switch b.type {
        case .tank, .speedster:
            switch b.attackPattern {
            case 0:
                let angle = Double.pi / 2, speed: CGFloat = 120
                bullets.append(Bullet(position: b.position, velocity: CGVector(dx: CGFloat(cos(angle)) * speed, dy: CGFloat(sin(angle)) * speed), isEnemy: true))
            case 1:
                let dx = playerPos.x - b.position.x, dy = playerPos.y - b.position.y
                let len = max(hypot(dx, dy), 1), speed: CGFloat = 150
                bullets.append(Bullet(position: b.position, velocity: CGVector(dx: dx/len * speed, dy: dy/len * speed), isEnemy: true))
            case 2:
                enemies.append(Enemy(position: CGPoint(x: b.position.x, y: b.position.y + 30), velocity: CGVector(dx: 0, dy: 100), type: .scout, hp: 1))
            default: break
            }
            
        case .teleporter:
            b.position.x = .random(in: 60...(size.width - 60))
            b.teleportTimer = Date.now
            spawnHitParticles(at: b.position, color: .purple, count: 20)
            let angle = Double.pi / 2
            let speed: CGFloat = 140
            bullets.append(Bullet(position: b.position, velocity: CGVector(dx: CGFloat(cos(angle)) * speed, dy: CGFloat(sin(angle)) * speed), isEnemy: true))
            
        case .splitter:
            let angle1 = Double.pi / 2 - 0.2
            let angle2 = Double.pi / 2 + 0.2
            let speed: CGFloat = 120
            bullets.append(Bullet(position: b.position, velocity: CGVector(dx: CGFloat(cos(angle1)) * speed, dy: CGFloat(sin(angle1)) * speed), isEnemy: true))
            bullets.append(Bullet(position: b.position, velocity: CGVector(dx: CGFloat(cos(angle2)) * speed, dy: CGFloat(sin(angle2)) * speed), isEnemy: true))
            
        case .shield:
            let angle = Double.pi / 2
            let speed: CGFloat = 130
            bullets.append(Bullet(position: b.position, velocity: CGVector(dx: CGFloat(cos(angle)) * speed, dy: CGFloat(sin(angle)) * speed), isEnemy: true))
            
        case .summoner:
            let x = b.position.x
            enemies.append(Enemy(position: CGPoint(x: x, y: b.position.y + 40), velocity: CGVector(dx: 0, dy: 90), type: .scout, hp: 1))
        }
        
        b.lastAttack = Date.now
        boss = b
    }
    
    func finishGame() {
        if score > highScore { highScore = score; SaveManager.shared.highScore = highScore; isNewRecord = true }
        SaveManager.shared.crystals += crystalsEarned
        updateDailyQuests()
    }
    
    private func updateDailyQuests() {
        var quests = SaveManager.shared.dailyQuests
        let today = Calendar.current.startOfDay(for: Date())
        if SaveManager.shared.dailyQuestDate != today.description {
            quests = DailyQuest.generateNew()
            SaveManager.shared.dailyQuestDate = today.description
        }
        for i in quests.indices {
            if quests[i].completed { continue }
            switch quests[i].title {
            case "Уничтожь 50 врагов": quests[i].progress = min(enemiesKilled, quests[i].target)
            case "Набери 500 очков": quests[i].progress = min(score, quests[i].target)
            case "Победи 1 босса": quests[i].progress = min(bossesKilled, quests[i].target)
            case "Собери 10 бонусов": quests[i].progress = min(powerUpsCollected, quests[i].target)
            case "Сыграй 3 игры": quests[i].progress = min(SaveManager.shared.gamesPlayed, quests[i].target)
            default: break
            }
            if quests[i].progress >= quests[i].target && !quests[i].completed {
                quests[i].completed = true
                SaveManager.shared.crystals += quests[i].reward
            }
        }
        SaveManager.shared.dailyQuests = quests
    }
    
    private func shoot() {
        let baseSpeed: CGFloat = 700
        let speed = baseSpeed * fireRateMultiplier
        let dmgMultiplier = damageMultiplier
        
        func createBullet(offsetX: CGFloat = 0) -> Bullet {
            let baseDamage: Int
            switch currentWeapon {
            case .standard: baseDamage = 1
            case .shotgun: baseDamage = 1
            case .laser: baseDamage = 2
            case .homing: baseDamage = 3
            }
            let damage = max(1, Int(Double(baseDamage) * dmgMultiplier))
            return Bullet(
                position: CGPoint(x: playerPos.x + offsetX, y: playerPos.y - 20),
                velocity: CGVector(dx: 0, dy: -speed),
                isEnemy: false,
                damage: damage,
                weaponType: currentWeapon
            )
        }
        
        switch currentWeapon {
        case .standard:
            bullets.append(createBullet())
            if isDoubleShot { bullets.append(createBullet(offsetX: 15)) }
        case .shotgun:
            for i in -2...2 {
                let angle = Double(i) * 0.15 - (Double.pi / 2)
                bullets.append(Bullet(position: playerPos, velocity: CGVector(dx: CGFloat(cos(angle)) * speed, dy: CGFloat(sin(angle)) * speed), isEnemy: false, damage: max(1, Int(Double(1) * dmgMultiplier)), weaponType: .shotgun))
            }
        case .laser:
            bullets.append(createBullet())
            if isDoubleShot { bullets.append(createBullet(offsetX: 15)) }
        case .homing:
            bullets.append(createBullet())
            if isDoubleShot { bullets.append(createBullet(offsetX: 15)) }
        }
        SoundManager.shared.playShoot(type: currentWeapon)
    }
    
    private func spawnEnemy(size: CGSize) {
        let roll = Double.random(in: 0...1)
        let type: EnemyType = roll < 0.55 ? .scout : (roll < 0.85 ? .fighter : .tank)
        let x = CGFloat.random(in: 40...(size.width - 40))
        let hp: Int; let speed: CGFloat
        switch type {
        case .scout: hp = 1; speed = 180 + CGFloat(wave) * 8
        case .fighter: hp = 2; speed = 120 + CGFloat(wave) * 5
        case .tank: hp = 5; speed = 70 + CGFloat(wave) * 3
        }
        enemies.append(Enemy(position: CGPoint(x: x, y: -30), velocity: CGVector(dx: 0, dy: speed), type: type, hp: hp))
    }
    
    private func takeDamage(_ amount: Int) {
        playerHP -= amount
        shakeAmount = 12
        triggerHaptic(.heavy)
        spawnHitParticles(at: playerPos, color: .red, count: 10)
        if playerHP <= 0 { playerHP = 0; isGameOver = true; finishGame(); spawnExplosion(at: playerPos, type: .tank) }
    }
    
    private func enemyScore(_ type: EnemyType) -> Int {
        switch type { case .scout: 10; case .fighter: 25; case .tank: 60 }
    }
    
    private func spawnExplosion(at pos: CGPoint, type: EnemyType) {
        let count: Int; let color: Color
        switch type { case .scout: count = 20; color = .pink; case .fighter: count = 35; color = .orange; case .tank: count = 60; color = .red }
        for _ in 0..<count {
            let angle = Double.random(in: 0...(2 * Double.pi)), speed = CGFloat.random(in: 80...280)
            particles.append(Particle(position: pos, velocity: CGVector(dx: CGFloat(cos(angle)) * speed, dy: CGFloat(sin(angle)) * speed), life: Double.random(in: 0.4...1.0), maxLife: 1.0, color: color, size: CGFloat.random(in: 2...5)))
        }
        if type == .tank { shakeAmount = 15 }
    }
    
    private func spawnHitParticles(at pos: CGPoint, color: Color, count: Int) {
        for _ in 0..<count {
            let angle = Double.random(in: 0...(2 * Double.pi)), speed = CGFloat.random(in: 40...150)
            particles.append(Particle(position: pos, velocity: CGVector(dx: CGFloat(cos(angle)) * speed, dy: CGFloat(sin(angle)) * speed), life: 0.4, maxLife: 0.4, color: color, size: CGFloat.random(in: 1.5...3)))
        }
    }
}

// MARK: - Джойстик
struct VirtualJoystick: View {
    @Binding var vector: CGVector
    @State private var knobPos: CGPoint = .zero
    @State private var isActive: Bool = false
    private let radius: CGFloat = 60
    
    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            ZStack {
                Circle().stroke(Color.white.opacity(0.2), lineWidth: 2).background(Circle().fill(Color.white.opacity(0.05))).frame(width: radius * 2, height: radius * 2)
                Circle().fill(RadialGradient(colors: [.cyan.opacity(0.9), .cyan.opacity(0.4)], center: .center, startRadius: 2, endRadius: 25)).frame(width: 50, height: 50).shadow(color: .cyan, radius: 10).position(isActive ? knobPos : center)
            }
            .contentShape(Circle().size(CGSize(width: radius * 3, height: radius * 3)))
            .gesture(DragGesture(minimumDistance: 0).onChanged { value in
                isActive = true
                let dx = value.location.x - center.x, dy = value.location.y - center.y
                let dist = min(hypot(dx, dy), radius), angle = atan2(dy, dx)
                knobPos = CGPoint(x: center.x + cos(angle) * dist, y: center.y + sin(angle) * dist)
                vector = CGVector(dx: cos(angle) * dist / radius, dy: sin(angle) * dist / radius)
            }.onEnded { _ in isActive = false; vector = .zero })
        }
    }
}

// MARK: - Главный View
struct ContentView: View {
    @State private var engine = GameEngine()
    @State private var showIntro = true
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if showIntro {
                    IntroView { showIntro = false }
                } else {
                    TimelineView(.animation) { timeline in
                        Canvas { context, size in
                            if engine.shakeAmount > 0 && !engine.isPaused {
                                context.translateBy(x: .random(in: -engine.shakeAmount...engine.shakeAmount), y: .random(in: -engine.shakeAmount...engine.shakeAmount))
                            }
                            drawBackground(context: context, size: size)
                            drawStars(context: context)
                            drawPowerUps(context: context)
                            drawEnemies(context: context)
                            drawBoss(context: context)
                            drawBullets(context: context)
                            drawParticles(context: context)
                            
                            // Красная вспышка при уроне
                            if engine.shakeAmount > 5 {
                                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.red.opacity(0.2)))
                            }
                            
                            if engine.isPlaying && !engine.isGameOver && !engine.isPaused { drawPlayer(context: context) }
                        }
                        .allowsHitTesting(false)
                        .onChange(of: timeline.date) { _, newDate in engine.update(now: newDate, size: geo.size) }
                    }
                    
                    if engine.isBombActive { Color.white.opacity(engine.bombFlashOpacity).ignoresSafeArea().allowsHitTesting(false) }
                    
                    if engine.isPlaying && !engine.isGameOver && !engine.isPaused {
                        VStack {
                            if let boss = engine.boss {
                                VStack(spacing: 4) {
                                    Text("⚠️ \(boss.type.name) ⚠️").font(.caption.bold()).foregroundStyle(boss.type.color).shadow(color: boss.type.color, radius: 5)
                                    ZStack(alignment: .leading) {
                                        Capsule().fill(Color.white.opacity(0.15)).frame(height: 12)
                                        Capsule().fill(LinearGradient(colors: [boss.type.color, boss.type.color.opacity(0.5)], startPoint: .leading, endPoint: .trailing)).frame(width: 200 * CGFloat(boss.hp) / CGFloat(boss.maxHP), height: 12)
                                    }.frame(width: 200)
                                    if boss.type == .shield {
                                        Text("Пушки: \(engine.shieldGunsDestroyed)/\(engine.totalShieldGuns)").font(.caption2).foregroundStyle(.white.opacity(0.7))
                                    }
                                }.padding(.top, 60)
                            }
                            
                            if engine.comboCount >= 3 {
                                HStack(spacing: 8) {
                                    Text("COMBO x\(engine.comboMultiplier)").font(.system(size: 24, weight: .black, design: .rounded))
                                        .foregroundStyle(engine.comboMultiplier >= 10 ? Color.red : engine.comboMultiplier >= 5 ? Color.orange : engine.comboMultiplier >= 3 ? Color.yellow : Color.cyan)
                                        .shadow(color: engine.comboMultiplier >= 5 ? .orange : .cyan, radius: 10).scaleEffect(engine.comboScale)
                                    Text("\(engine.comboCount)").font(.system(size: 20, weight: .bold, design: .rounded)).foregroundStyle(.white.opacity(0.8))
                                }.opacity(engine.comboDisplayOpacity).padding(.top, 60)
                            }
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("HP").font(.caption.bold()).foregroundStyle(.white.opacity(0.7))
                                    ZStack(alignment: .leading) {
                                        Capsule().fill(Color.white.opacity(0.15)).frame(height: 10)
                                        Capsule().fill(LinearGradient(colors: [.green, .yellow, .red], startPoint: .leading, endPoint: .trailing)).frame(width: 120 * CGFloat(engine.playerHP) / CGFloat(engine.maxHP), height: 10)
                                    }.frame(width: 120)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("\(engine.score)").font(.title.bold()).foregroundStyle(.white)
                                    Text("WAVE \(engine.wave)").font(.caption).foregroundStyle(.cyan)
                                }
                            }.padding(.horizontal, 20).padding(.top, 60)
                            
                            Spacer()
                            VirtualJoystick(vector: Binding(get: { engine.joystickVector }, set: { engine.joystickVector = $0 })).frame(width: 180, height: 180).padding(.leading, 30).padding(.bottom, 40).frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    if engine.isPlaying && !engine.isGameOver {
                        VStack {
                            HStack {
                                Button { engine.useBomb() } label: {
                                    ZStack(alignment: .bottomTrailing) {
                                        Circle().fill(engine.bombs > 0 ? Color.red : Color.gray).frame(width: 55, height: 55).overlay(Circle().stroke(.white.opacity(0.8), lineWidth: 2)).shadow(color: engine.bombs > 0 ? .red : .clear, radius: 10)
                                        Image(systemName: "flame.fill").font(.title2).foregroundStyle(.white)
                                        Text("\(engine.bombs)").font(.caption.bold()).foregroundStyle(.white).padding(4).background(Color.black.opacity(0.6), in: Circle()).offset(x: 12, y: 12)
                                    }
                                }.disabled(engine.bombs <= 0).padding(.leading, 20).padding(.top, 60)
                                Spacer()
                                Button { engine.togglePause() } label: {
                                    Image(systemName: engine.isPaused ? "play.fill" : "pause.fill").font(.system(size: 28, weight: .bold)).foregroundStyle(.white).frame(width: 56, height: 56).background(.ultraThinMaterial, in: Circle()).overlay(Circle().stroke(.white.opacity(0.5), lineWidth: 2)).shadow(color: .cyan.opacity(0.6), radius: 10)
                                }.contentShape(Circle()).padding(.trailing, 20).padding(.top, 60)
                            }
                            Spacer()
                        }
                    }
                    
                    if let popup = engine.activePopup {
                        AchievementPopupView(achievement: popup.achievement).transition(.move(edge: .top).combined(with: .opacity)).padding(.top, 60).frame(maxWidth: .infinity, alignment: .center).allowsHitTesting(false)
                    }
                    if engine.isPaused && !engine.showUpgradeChoice { PauseMenuView(engine: engine, size: geo.size) }
                    if !engine.isPlaying || engine.isGameOver { MenuView(engine: engine, size: geo.size) }
                    
                    if engine.showWaveComplete {
                        WaveCompleteView(wave: engine.wave).allowsHitTesting(false)
                    }
                    
                    if !engine.showWaveComplete && engine.showUpgradeChoice {
                        UpgradeChoiceView(upgrades: engine.pendingUpgrades) { upgrade in
                            engine.applyUpgrade(upgrade)
                        }
                    }
                }
            }
            .ignoresSafeArea().background(Color.black)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: engine.activePopup?.id)
            .animation(.easeInOut(duration: 0.3), value: engine.isPaused)
        }.preferredColorScheme(.dark)
    }
    
    func drawBoss(context: GraphicsContext) {
        guard let boss = engine.boss else { return }
        let p = boss.position, size: CGFloat = 55
        let pulse = 1.0 + 0.05 * sin(Date().timeIntervalSinceReferenceDate * 4), s = size * pulse
        
        switch boss.type {
        case .splitter:
            context.drawLayer { layer in layer.addFilter(.blur(radius: 30)); layer.fill(Path(ellipseIn: CGRect(x: p.x - s * 1.2, y: p.y - s * 1.2, width: s * 2.4, height: s * 2.4)), with: .color(.pink.opacity(0.4))) }
            context.fill(Path(ellipseIn: CGRect(x: p.x - s * 0.9, y: p.y - s * 0.9, width: s * 1.8, height: s * 1.8)), with: .color(.pink))
            context.stroke(Path(ellipseIn: CGRect(x: p.x - s * 0.9, y: p.y - s * 0.9, width: s * 1.8, height: s * 1.8)), with: .color(.white.opacity(0.8)), lineWidth: 2)
            for i in 0..<3 {
                let angle = Double(i) * (Double.pi * 2 / 3)
                var crack = Path(); crack.move(to: CGPoint(x: p.x, y: p.y)); crack.addLine(to: CGPoint(x: p.x + cos(angle) * s * 0.8, y: p.y + sin(angle) * s * 0.8))
                context.stroke(crack, with: .color(.white), lineWidth: 3)
            }
            return
        case .shield:
            context.drawLayer { layer in layer.addFilter(.blur(radius: 30)); layer.fill(Path(ellipseIn: CGRect(x: p.x - s * 1.2, y: p.y - s * 1.2, width: s * 2.4, height: s * 2.4)), with: .color(.blue.opacity(0.4))) }
            context.fill(Path(ellipseIn: CGRect(x: p.x - s * 0.9, y: p.y - s * 0.9, width: s * 1.8, height: s * 1.8)), with: .color(.blue))
            context.stroke(Path(ellipseIn: CGRect(x: p.x - s * 0.9, y: p.y - s * 0.9, width: s * 1.8, height: s * 1.8)), with: .color(.white.opacity(0.8)), lineWidth: 2)
            let gunPositions = [(-0.7, -0.7), (0.7, -0.7), (-0.7, 0.7), (0.7, 0.7)]
            for (idx, pos) in gunPositions.enumerated() {
                let gx = p.x + pos.0 * s * 0.9, gy = p.y + pos.1 * s * 0.9
                let gunRect = CGRect(x: gx - 12, y: gy - 12, width: 24, height: 24)
                if idx < engine.shieldGunsDestroyed {
                    context.fill(Path(ellipseIn: gunRect), with: .color(.gray.opacity(0.3)))
                    context.stroke(Path(ellipseIn: gunRect), with: .color(.white.opacity(0.3)), lineWidth: 1)
                } else {
                    context.fill(Path(ellipseIn: gunRect), with: .color(.cyan))
                    context.stroke(Path(ellipseIn: gunRect), with: .color(.white), lineWidth: 2)
                    context.drawLayer { layer in layer.addFilter(.blur(radius: 5)); layer.fill(Path(ellipseIn: gunRect), with: .color(.cyan.opacity(0.6))) }
                }
            }
            if engine.shieldGunsDestroyed < engine.totalShieldGuns {
                context.stroke(Path(ellipseIn: CGRect(x: p.x - s * 1.1, y: p.y - s * 1.1, width: s * 2.2, height: s * 2.2)), with: .color(.cyan.opacity(0.5)), lineWidth: 4)
            }
            return
        case .summoner:
            context.drawLayer { layer in layer.addFilter(.blur(radius: 30)); layer.fill(Path(ellipseIn: CGRect(x: p.x - s * 1.2, y: p.y - s * 1.2, width: s * 2.4, height: s * 2.4)), with: .color(.green.opacity(0.4))) }
            context.fill(Path(ellipseIn: CGRect(x: p.x - s * 0.9, y: p.y - s * 0.9, width: s * 1.8, height: s * 1.8)), with: .color(.green))
            context.stroke(Path(ellipseIn: CGRect(x: p.x - s * 0.9, y: p.y - s * 0.9, width: s * 1.8, height: s * 1.8)), with: .color(.white.opacity(0.8)), lineWidth: 2)
            for i in 0..<3 {
                let angle = Double(i) * (Double.pi * 2 / 3) - Double.pi / 2
                let eyeX = p.x + cos(angle) * s * 0.5, eyeY = p.y + sin(angle) * s * 0.5
                let eyeRect = CGRect(x: eyeX - 10, y: eyeY - 10, width: 20, height: 20)
                context.fill(Path(ellipseIn: eyeRect), with: .color(.white))
                context.fill(Path(ellipseIn: CGRect(x: eyeX - 5, y: eyeY - 5, width: 10, height: 10)), with: .color(.black))
            }
            return
        default:
            break
        }
        
        context.drawLayer { layer in layer.addFilter(.blur(radius: 30)); layer.fill(Path(ellipseIn: CGRect(x: p.x - s * 1.2, y: p.y - s * 1.2, width: s * 2.4, height: s * 2.4)), with: .color(boss.type.color.opacity(0.4))) }
        let shieldAngle = Date().timeIntervalSinceReferenceDate * 2
        for i in 0..<6 {
            let angle = shieldAngle + Double(i) * (Double.pi / 3)
            let shieldRect = CGRect(x: p.x + cos(angle) * s * 1.1 - 8, y: p.y + sin(angle) * s * 1.1 - 8, width: 16, height: 16)
            context.fill(Path(ellipseIn: shieldRect), with: .color(boss.type.color.opacity(0.6)))
            context.stroke(Path(ellipseIn: shieldRect), with: .color(.white.opacity(0.8)), lineWidth: 1)
        }
        let bodyRect = CGRect(x: p.x - s * 0.9, y: p.y - s * 0.9, width: s * 1.8, height: s * 1.8)
        context.fill(Path(ellipseIn: bodyRect), with: .color(.gray.opacity(0.8)))
        context.stroke(Path(ellipseIn: bodyRect), with: .color(.white.opacity(0.6)), lineWidth: 2)
        let armorRect = CGRect(x: p.x - s * 0.7, y: p.y - s * 0.7, width: s * 1.4, height: s * 1.4)
        context.fill(Path(ellipseIn: armorRect), with: .color(boss.type.color.opacity(0.7)))
        context.stroke(Path(ellipseIn: armorRect), with: .color(.white.opacity(0.5)), lineWidth: 1.5)
        for i in 0..<4 {
            let angle = Double(i) * (Double.pi / 2) + Date().timeIntervalSinceReferenceDate * 0.5
            var line = Path(); line.move(to: CGPoint(x: p.x + cos(angle) * s * 0.5, y: p.y + sin(angle) * s * 0.5)); line.addLine(to: CGPoint(x: p.x + cos(angle) * s * 0.7, y: p.y + sin(angle) * s * 0.7))
            context.stroke(line, with: .color(.white.opacity(0.4)), lineWidth: 2)
        }
        let corePulse = 0.8 + 0.2 * sin(Date().timeIntervalSinceReferenceDate * 6), coreSize = s * 0.35 * corePulse
        let coreRect = CGRect(x: p.x - coreSize, y: p.y - coreSize, width: coreSize * 2, height: coreSize * 2)
        context.drawLayer { layer in layer.addFilter(.blur(radius: 12)); layer.fill(Path(ellipseIn: coreRect), with: .color(boss.type.color)) }
        context.fill(Path(ellipseIn: coreRect), with: .color(.white))
        context.fill(Path(ellipseIn: coreRect.insetBy(dx: 3, dy: 3)), with: .color(boss.type.color))
        for side in [-1.0, 1.0] {
            let baseRect = CGRect(x: p.x + side * s * 0.85 - 12, y: p.y - 18, width: 24, height: 36)
            context.fill(Path(roundedRect: baseRect, cornerRadius: 6), with: .color(.gray))
            context.stroke(Path(roundedRect: baseRect, cornerRadius: 6), with: .color(.white.opacity(0.6)), lineWidth: 1.5)
            let barrelRect = CGRect(x: p.x + side * s * 0.85 - 7, y: p.y + 12, width: 14, height: 24)
            context.fill(Path(roundedRect: barrelRect, cornerRadius: 4), with: .color(.gray.opacity(0.5)))
            context.stroke(Path(roundedRect: barrelRect, cornerRadius: 4), with: .color(.white.opacity(0.4)), lineWidth: 1)
            let muzzleRect = CGRect(x: p.x + side * s * 0.85 - 5, y: p.y + 30, width: 10, height: 10)
            context.fill(Path(ellipseIn: muzzleRect), with: .color(boss.type.color.opacity(0.8)))
            context.drawLayer { layer in layer.addFilter(.blur(radius: 4)); layer.fill(Path(ellipseIn: muzzleRect), with: .color(boss.type.color)) }
        }
    }
    
    func drawBackground(context: GraphicsContext, size: CGSize) {
        let wave = engine.wave
        let colors: [Color]
        
        if wave <= 5 {
            colors = [Color(red: 0.02, green: 0.0, blue: 0.1), Color(red: 0.1, green: 0.0, blue: 0.25)]
        } else if wave <= 10 {
            colors = [Color(red: 0.1, green: 0.0, blue: 0.2), Color(red: 0.3, green: 0.0, blue: 0.4)]
        } else if wave <= 15 {
            colors = [Color(red: 0.2, green: 0.05, blue: 0.0), Color(red: 0.4, green: 0.1, blue: 0.0)]
        } else {
            colors = [Color(red: 0.0, green: 0.0, blue: 0.0), Color(red: 0.2, green: 0.0, blue: 0.3)]
        }
        
        context.fill(Path(CGRect(origin: .zero, size: size)), with: .linearGradient(Gradient(colors: colors), startPoint: .zero, endPoint: CGPoint(x: 0, y: size.height)))
    }
    
    func drawStars(context: GraphicsContext) {
        for star in engine.stars { context.fill(Path(ellipseIn: CGRect(x: star.position.x, y: star.position.y, width: star.size, height: star.size)), with: .color(.white.opacity(star.brightness))) }
    }
    
    func drawPlayer(context: GraphicsContext) {
        let p = engine.playerPos, shipColor = engine.currentSkin.color
        let flamePulse = 0.8 + 0.2 * sin(Date().timeIntervalSinceReferenceDate * 15), flameHeight: CGFloat = 25 * flamePulse, flameWidth: CGFloat = 14 * flamePulse
        context.drawLayer { layer in layer.addFilter(.blur(radius: 15)); layer.fill(Path(ellipseIn: CGRect(x: p.x - flameWidth/2, y: p.y + 18, width: flameWidth, height: flameHeight)), with: .color(shipColor.opacity(0.6))) }
        context.fill(Path(ellipseIn: CGRect(x: p.x - flameWidth/4, y: p.y + 20, width: flameWidth/2, height: flameHeight * 0.7)), with: .color(.white.opacity(0.8)))
        var bodyPath = Path(); bodyPath.move(to: CGPoint(x: p.x, y: p.y - 28)); bodyPath.addCurve(to: CGPoint(x: p.x, y: p.y + 20), control1: CGPoint(x: p.x + 15, y: p.y - 10), control2: CGPoint(x: p.x + 12, y: p.y + 10)); bodyPath.addCurve(to: CGPoint(x: p.x, y: p.y - 28), control1: CGPoint(x: p.x - 12, y: p.y + 10), control2: CGPoint(x: p.x - 15, y: p.y - 10)); bodyPath.closeSubpath()
        context.drawLayer { layer in layer.addFilter(.blur(radius: 10)); layer.fill(bodyPath, with: .color(shipColor)) }
        context.fill(bodyPath, with: .color(shipColor)); context.stroke(bodyPath, with: .color(.white.opacity(0.8)), lineWidth: 1.5)
        var leftWing = Path(); leftWing.move(to: CGPoint(x: p.x - 5, y: p.y + 5)); leftWing.addLine(to: CGPoint(x: p.x - 22, y: p.y + 15)); leftWing.addLine(to: CGPoint(x: p.x - 5, y: p.y + 18)); leftWing.closeSubpath()
        var rightWing = Path(); rightWing.move(to: CGPoint(x: p.x + 5, y: p.y + 5)); rightWing.addLine(to: CGPoint(x: p.x + 22, y: p.y + 15)); rightWing.addLine(to: CGPoint(x: p.x + 5, y: p.y + 18)); rightWing.closeSubpath()
        context.fill(leftWing, with: .color(shipColor)); context.fill(rightWing, with: .color(shipColor))
        context.stroke(leftWing, with: .color(.white.opacity(0.6)), lineWidth: 1); context.stroke(rightWing, with: .color(.white.opacity(0.6)), lineWidth: 1)
        let cockpitPath = Path(ellipseIn: CGRect(x: p.x - 6, y: p.y - 15, width: 12, height: 18))
        context.drawLayer { layer in layer.addFilter(.blur(radius: 5)); layer.fill(cockpitPath, with: .color(.cyan.opacity(0.6))) }
        context.fill(cockpitPath, with: .color(.cyan)); context.stroke(cockpitPath, with: .color(.white.opacity(0.9)), lineWidth: 1)
        context.fill(Path(ellipseIn: CGRect(x: p.x - 3, y: p.y - 12, width: 4, height: 8)), with: .color(.white.opacity(0.7)))
    }
    
    func drawEnemies(context: GraphicsContext) {
        for e in engine.enemies {
            let p = e.position
            switch e.type {
            case .scout:
                let size: CGFloat = 16
                context.drawLayer { layer in layer.addFilter(.blur(radius: 8)); layer.fill(Path(ellipseIn: CGRect(x: p.x - size, y: p.y - size, width: size*2, height: size*2)), with: .color(.pink.opacity(0.5))) }
                var body = Path(); body.move(to: CGPoint(x: p.x, y: p.y + size)); body.addLine(to: CGPoint(x: p.x - size * 0.8, y: p.y - size * 0.6)); body.addLine(to: CGPoint(x: p.x - size * 0.3, y: p.y - size * 0.3)); body.addLine(to: CGPoint(x: p.x + size * 0.3, y: p.y - size * 0.3)); body.addLine(to: CGPoint(x: p.x + size * 0.8, y: p.y - size * 0.6)); body.closeSubpath()
                context.fill(body, with: .color(.pink)); context.stroke(body, with: .color(.white.opacity(0.8)), lineWidth: 1.5)
                context.fill(Path(ellipseIn: CGRect(x: p.x - 3, y: p.y - 2, width: 6, height: 6)), with: .color(.white.opacity(0.9)))
                let flameRect = CGRect(x: p.x - 2, y: p.y - size * 0.6 - 4, width: 4, height: 4)
                context.drawLayer { layer in layer.addFilter(.blur(radius: 3)); layer.fill(Path(ellipseIn: flameRect), with: .color(.pink.opacity(0.8))) }
            case .fighter:
                let size: CGFloat = 22
                context.drawLayer { layer in layer.addFilter(.blur(radius: 12)); layer.fill(Path(ellipseIn: CGRect(x: p.x - size, y: p.y - size, width: size*2, height: size*2)), with: .color(.orange.opacity(0.5))) }
                var body = Path(); body.move(to: CGPoint(x: p.x, y: p.y + size)); body.addLine(to: CGPoint(x: p.x - size * 0.4, y: p.y)); body.addLine(to: CGPoint(x: p.x - size * 0.9, y: p.y - size * 0.3)); body.addLine(to: CGPoint(x: p.x - size * 0.5, y: p.y - size * 0.5)); body.addLine(to: CGPoint(x: p.x - size * 0.3, y: p.y - size * 0.8)); body.addLine(to: CGPoint(x: p.x + size * 0.3, y: p.y - size * 0.8)); body.addLine(to: CGPoint(x: p.x + size * 0.5, y: p.y - size * 0.5)); body.addLine(to: CGPoint(x: p.x + size * 0.9, y: p.y - size * 0.3)); body.addLine(to: CGPoint(x: p.x + size * 0.4, y: p.y)); body.closeSubpath()
                context.fill(body, with: .color(.orange)); context.stroke(body, with: .color(.white.opacity(0.7)), lineWidth: 1.5)
                context.fill(Path(ellipseIn: CGRect(x: p.x - 4, y: p.y, width: 8, height: 10)), with: .color(.white.opacity(0.9)))
                for side in [-1.0, 1.0] {
                    context.fill(Path(roundedRect: CGRect(x: p.x + side * size * 0.7 - 2, y: p.y + size * 0.3, width: 4, height: 8), cornerRadius: 1), with: .color(.gray))
                    let fRect = CGRect(x: p.x + side * size * 0.5 - 2.5, y: p.y - size * 0.8 - 5, width: 5, height: 5)
                    context.drawLayer { layer in layer.addFilter(.blur(radius: 4)); layer.fill(Path(ellipseIn: fRect), with: .color(.orange.opacity(0.8))) }
                }
            case .tank:
                let size: CGFloat = 30
                context.drawLayer { layer in layer.addFilter(.blur(radius: 15)); layer.fill(Path(ellipseIn: CGRect(x: p.x - size, y: p.y - size, width: size*2, height: size*2)), with: .color(.red.opacity(0.5))) }
                var body = Path(); body.move(to: CGPoint(x: p.x, y: p.y + size)); body.addLine(to: CGPoint(x: p.x - size * 0.5, y: p.y + size * 0.5)); body.addLine(to: CGPoint(x: p.x - size, y: p.y)); body.addLine(to: CGPoint(x: p.x - size * 0.9, y: p.y - size * 0.6)); body.addLine(to: CGPoint(x: p.x - size * 0.5, y: p.y - size * 0.8)); body.addLine(to: CGPoint(x: p.x + size * 0.5, y: p.y - size * 0.8)); body.addLine(to: CGPoint(x: p.x + size * 0.9, y: p.y - size * 0.6)); body.addLine(to: CGPoint(x: p.x + size, y: p.y)); body.addLine(to: CGPoint(x: p.x + size * 0.5, y: p.y + size * 0.5)); body.closeSubpath()
                context.fill(body, with: .color(.red)); context.stroke(body, with: .color(.white.opacity(0.6)), lineWidth: 2)
                context.fill(Path(roundedRect: CGRect(x: p.x - size * 0.6, y: p.y - size * 0.5, width: size * 1.2, height: size * 1.0), cornerRadius: 4), with: .color(.red.opacity(0.7)))
                context.stroke(Path(roundedRect: CGRect(x: p.x - size * 0.6, y: p.y - size * 0.5, width: size * 1.2, height: size * 1.0), cornerRadius: 4), with: .color(.white.opacity(0.5)), lineWidth: 1)
                context.fill(Path(roundedRect: CGRect(x: p.x - 6, y: p.y - 4, width: 12, height: 14), cornerRadius: 3), with: .color(.white.opacity(0.9)))
                for pos in [(-0.8, 0.3), (0.8, 0.3), (-0.6, 0.6), (0.6, 0.6)] {
                    let gRect = CGRect(x: p.x + pos.0 * size - 3, y: p.y + pos.1 * size, width: 6, height: 10)
                    context.fill(Path(roundedRect: gRect, cornerRadius: 2), with: .color(.gray))
                    context.stroke(Path(roundedRect: gRect, cornerRadius: 2), with: .color(.white.opacity(0.5)), lineWidth: 1)
                }
                for side in [-1.0, 1.0] {
                    let fRect = CGRect(x: p.x + side * size * 0.4 - 4, y: p.y - size * 0.8 - 8, width: 8, height: 12)
                    context.drawLayer { layer in layer.addFilter(.blur(radius: 5)); layer.fill(Path(ellipseIn: fRect), with: .color(.red.opacity(0.8))) }
                }
                let hpRatio = CGFloat(e.hp) / 5.0
                context.fill(Path(roundedRect: CGRect(x: p.x - 25, y: p.y - size - 15, width: 50, height: 5), cornerRadius: 2), with: .color(.white.opacity(0.3)))
                context.fill(Path(roundedRect: CGRect(x: p.x - 25, y: p.y - size - 15, width: 50 * hpRatio, height: 5), cornerRadius: 2), with: .color(.red))
            }
        }
    }
    
    func drawBullets(context: GraphicsContext) {
        for b in engine.bullets {
            if b.isEnemy {
                let radius: CGFloat = 9
                context.drawLayer { layer in layer.addFilter(.blur(radius: 12)); layer.fill(Path(ellipseIn: CGRect(x: b.position.x - radius * 2, y: b.position.y - radius * 2, width: radius * 4, height: radius * 4)), with: .color(.red.opacity(0.5))) }
                context.fill(Path(ellipseIn: CGRect(x: b.position.x - radius, y: b.position.y - radius, width: radius * 2, height: radius * 2)), with: .color(.red))
                context.fill(Path(ellipseIn: CGRect(x: b.position.x - radius * 0.5, y: b.position.y - radius * 0.5, width: radius, height: radius)), with: .color(.white))
                for i in 1...4 {
                    let tailRadius = radius * (1.0 - CGFloat(i) * 0.2), tailY = b.position.y - radius - CGFloat(i) * 8
                    context.fill(Path(ellipseIn: CGRect(x: b.position.x - tailRadius, y: tailY - tailRadius, width: tailRadius * 2, height: tailRadius * 2)), with: .color(.red.opacity(0.6 - CGFloat(i) * 0.15)))
                }
            } else {
                let color: Color = b.weaponType == .laser ? .cyan : (b.weaponType == .homing ? .purple : .yellow)
                let w: CGFloat = b.weaponType == .laser ? 6 : 4, h: CGFloat = b.weaponType == .laser ? 24 : 16
                let rect = CGRect(x: b.position.x - w/2, y: b.position.y - h/2, width: w, height: h)
                context.drawLayer { layer in layer.addFilter(.blur(radius: 4)); layer.fill(Path(rect), with: .color(color)) }
                context.fill(Path(rect), with: .color(.white))
            }
        }
    }
    
    func drawParticles(context: GraphicsContext) {
        for p in engine.particles {
            let alpha = p.life / p.maxLife
            context.fill(Path(ellipseIn: CGRect(x: p.position.x - p.size/2, y: p.position.y - p.size/2, width: p.size, height: p.size)), with: .color(p.color.opacity(alpha)))
        }
    }
    
    func drawPowerUps(context: GraphicsContext) {
        for pu in engine.powerUps {
            let size: CGFloat = 28
            context.drawLayer { layer in
                layer.addFilter(.blur(radius: 12))
                let color: Color = pu.type == .health ? .green : (pu.type == .weapon ? .purple : .red)
                layer.fill(Path(ellipseIn: CGRect(x: pu.position.x - size/2 - 5, y: pu.position.y - size/2 - 5, width: size + 10, height: size + 10)), with: .color(color.opacity(0.6)))
            }
            let boxRect = CGRect(x: pu.position.x - size/2, y: pu.position.y - size/2, width: size, height: size)
            let color: Color = pu.type == .health ? .green : (pu.type == .weapon ? .purple : .red)
            context.fill(Path(roundedRect: boxRect, cornerRadius: 6), with: .color(color))
            context.stroke(Path(roundedRect: boxRect, cornerRadius: 6), with: .color(.white.opacity(0.8)), lineWidth: 2)
            context.fill(Path(roundedRect: CGRect(x: pu.position.x - size/2 + 3, y: pu.position.y - size/2 + 3, width: size - 6, height: (size - 6) / 2), cornerRadius: 3), with: .color(.white.opacity(0.3)))
            
            if pu.type == .health {
                context.fill(Path(roundedRect: CGRect(x: pu.position.x - 5, y: pu.position.y - 2, width: 10, height: 4), cornerRadius: 1), with: .color(.white))
                context.fill(Path(roundedRect: CGRect(x: pu.position.x - 2, y: pu.position.y - 5, width: 4, height: 10), cornerRadius: 1), with: .color(.white))
            } else if pu.type == .weapon {
                var lightning = Path(); lightning.move(to: CGPoint(x: pu.position.x + 2, y: pu.position.y - 7)); lightning.addLine(to: CGPoint(x: pu.position.x - 3, y: pu.position.y)); lightning.addLine(to: CGPoint(x: pu.position.x + 1, y: pu.position.y)); lightning.addLine(to: CGPoint(x: pu.position.x - 2, y: pu.position.y + 7)); lightning.addLine(to: CGPoint(x: pu.position.x + 3, y: pu.position.y)); lightning.addLine(to: CGPoint(x: pu.position.x - 1, y: pu.position.y)); lightning.closeSubpath()
                context.fill(lightning, with: .color(.yellow))
            } else {
                context.fill(Path(ellipseIn: CGRect(x: pu.position.x - 6, y: pu.position.y - 4, width: 12, height: 12)), with: .color(.black))
                var fuse = Path(); fuse.move(to: CGPoint(x: pu.position.x, y: pu.position.y - 4)); fuse.addLine(to: CGPoint(x: pu.position.x + 3, y: pu.position.y - 8))
                context.stroke(fuse, with: .color(.orange), lineWidth: 2)
                context.fill(Path(ellipseIn: CGRect(x: pu.position.x + 1, y: pu.position.y - 10, width: 4, height: 4)), with: .color(.yellow))
            }
        }
    }
}

// MARK: - Заставка при входе
struct IntroView: View {
    @State private var logoOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.5
    @State private var glowRadius: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var subtitleBlink: Bool = false
    @State private var starsOpacity: Double = 0
    let onStart: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()
                ForEach(0..<50) { i in
                    Circle().fill(Color.white).frame(width: CGFloat.random(in: 1...3), height: CGFloat.random(in: 1...3))
                        .position(x: CGFloat.random(in: 0...geo.size.width), y: CGFloat.random(in: 0...geo.size.height)).opacity(starsOpacity)
                }
                VStack(spacing: 30) {
                    Spacer()
                    Text("NEON STRIKE").font(.system(size: 52, weight: .black, design: .rounded)).foregroundStyle(.white)
                        .shadow(color: .cyan, radius: glowRadius).shadow(color: .cyan.opacity(0.5), radius: glowRadius * 2).opacity(logoOpacity).scaleEffect(logoScale)
                    Text("TAP TO START").font(.system(size: 20, weight: .bold, design: .rounded)).foregroundStyle(.cyan).opacity(subtitleOpacity).scaleEffect(subtitleBlink ? 1.1 : 1.0)
                    Spacer()
                    Text("v1.0").font(.caption).foregroundStyle(.white.opacity(0.3)).opacity(subtitleOpacity)
                }.padding()
            }
            .onAppear { animateIntro() }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.5)) { logoOpacity = 0; subtitleOpacity = 0; starsOpacity = 0 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { onStart() }
            }
        }
    }
    
    private func animateIntro() {
        withAnimation(.easeIn(duration: 1.0)) { starsOpacity = 0.8 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) { logoOpacity = 1; logoScale = 1 }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) { glowRadius = 25 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 0.5)) { subtitleOpacity = 1 }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) { subtitleBlink = true }
        }
    }
}

// MARK: - Экран завершения волны
struct WaveCompleteView: View {
    let wave: Int
    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            VStack(spacing: 15) {
                Text("ВОЛНА \(wave - 1)").font(.system(size: 48, weight: .black, design: .rounded)).foregroundStyle(.white).shadow(color: .cyan, radius: 20)
                Text("ПРОЙДЕНА!").font(.system(size: 32, weight: .bold, design: .rounded)).foregroundStyle(.cyan).shadow(color: .cyan, radius: 10)
            }.transition(.scale.combined(with: .opacity))
        }
    }
}

// MARK: - Экран выбора апгрейдов
struct UpgradeChoiceView: View {
    let upgrades: [UpgradeType]
    let onSelect: (UpgradeType) -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("УРОВЕНЬ ПРОЙДЕН!").font(.system(size: 36, weight: .black, design: .rounded)).foregroundStyle(.yellow).shadow(color: .yellow, radius: 15)
                Text("Выбери улучшение").font(.title3).foregroundStyle(.white.opacity(0.8))
                VStack(spacing: 15) {
                    ForEach(upgrades, id: \.self) { upgrade in
                        Button { onSelect(upgrade) } label: {
                            HStack(spacing: 15) {
                                Image(systemName: upgrade.icon).font(.system(size: 32)).foregroundStyle(.cyan).frame(width: 50)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(upgrade.rawValue).font(.headline).foregroundStyle(.white)
                                    Text(upgrade.description).font(.caption).foregroundStyle(.white.opacity(0.7))
                                }
                                Spacer()
                                Image(systemName: "arrow.right.circle.fill").font(.title2).foregroundStyle(.cyan)
                            }.padding().background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15)).overlay(RoundedRectangle(cornerRadius: 15).stroke(.cyan.opacity(0.5), lineWidth: 2)).shadow(color: .cyan.opacity(0.3), radius: 10)
                        }
                    }
                }.padding(.horizontal, 20)
            }.padding().transition(.scale.combined(with: .opacity))
        }
    }
}

// MARK: - Главное меню
struct MenuView: View {
    @Bindable var engine: GameEngine
    let size: CGSize
    @State private var showAchievements = false
    @State private var showShop = false
    @State private var showDailyReward = false
    @State private var showDailyQuests = false
    @State private var titleOpacity: Double = 0
    @State private var titleGlow: Double = 0
    @State private var titleOffset: CGFloat = -50
    @State private var buttonsOpacity: Double = 0
    @State private var buttonsOffset: CGFloat = 30
    @State private var playButtonScale: CGFloat = 0.8
    @State private var playButtonPulse: Bool = false
    @State private var crystalBadgeOpacity: Double = 0
    @State private var highScoreOpacity: Double = 0
    @State private var skinsOpacity: Double = 0
    @State private var weaponOpacity: Double = 0
    @State private var actionButtonsOpacity: Double = 0
    @State private var hintOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: 15) {
            Spacer().frame(height: 100)
            if engine.isGameOver {
                Text("ПОРАЖЕНИЕ").font(.system(size: 42, weight: .black, design: .rounded)).foregroundStyle(.white).shadow(color: .red, radius: 15)
                gameOverView(); reviveButton(); exitButton()
            } else {
                Text("NEON STRIKE").font(.system(size: 48, weight: .black, design: .rounded)).foregroundStyle(.white).shadow(color: .cyan, radius: titleGlow).opacity(titleOpacity).offset(y: titleOffset)
                crystalBadge(); highScoreView(); skinsScrollView()
                Text("Выбор оружия").font(.caption2).foregroundStyle(.white.opacity(0.5)).padding(.top, 5)
                weaponScrollView(); actionButtons(); achievementsButton(); hintView()
            }
            playButton()
        }
        .padding(30).background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 30))
        .overlay(RoundedRectangle(cornerRadius: 30).stroke(.white.opacity(0.2), lineWidth: 1)).padding()
        .sheet(isPresented: $showAchievements) { AchievementsView(engine: engine) }
        .sheet(isPresented: $showShop) { ShopView() }
        .sheet(isPresented: $showDailyReward) { DailyRewardView() }
        .sheet(isPresented: $showDailyQuests) { DailyQuestsView() }
        .onAppear { animateMenuAppearance() }
    }
    
    @ViewBuilder func gameOverView() -> some View {
        VStack(spacing: 8) {
            Text("Счёт: \(engine.score)").font(.title2).foregroundStyle(.white.opacity(0.8))
            HStack { Image(systemName: "trophy.fill").foregroundStyle(.yellow); Text("Рекорд: \(engine.highScore)").font(.headline).foregroundStyle(.yellow) }
            HStack { Image(systemName: "diamond.fill").foregroundStyle(.cyan); Text("+\(engine.crystalsEarned) кристаллов").font(.headline).foregroundStyle(.cyan) }
            if engine.isNewRecord { Text("🎉 НОВЫЙ РЕКОРД!").font(.caption.bold()).foregroundStyle(.green).transition(.scale) }
        }
    }
    @ViewBuilder func reviveButton() -> some View {
        if engine.canRevive { Button { engine.start(size: size, isRevive: true) } label: { HStack { Image(systemName: "play.rectangle.fill"); Text("Возродиться") }.font(.headline).foregroundStyle(.black).padding(.horizontal, 30).padding(.vertical, 12).background(.yellow, in: Capsule()).shadow(color: .yellow.opacity(0.5), radius: 10) }.padding(.top, 10) }
    }
    @ViewBuilder func exitButton() -> some View {
        Button { engine.exitToMenu() } label: { HStack { Image(systemName: "house.fill"); Text("Выйти в меню") }.font(.headline).foregroundStyle(.white).padding(.horizontal, 30).padding(.vertical, 12).background(.white.opacity(0.1), in: Capsule()).overlay(Capsule().stroke(.white.opacity(0.3), lineWidth: 1)) }.padding(.top, 10)
    }
    @ViewBuilder func crystalBadge() -> some View {
        HStack(spacing: 8) { Image(systemName: "diamond.fill").foregroundStyle(.cyan); Text("\(SaveManager.shared.crystals)").font(.headline).foregroundStyle(.white) }.padding(.horizontal, 16).padding(.vertical, 8).background(.ultraThinMaterial, in: Capsule()).overlay(Capsule().stroke(.cyan.opacity(0.5), lineWidth: 1)).opacity(crystalBadgeOpacity).offset(y: buttonsOffset)
    }
    @ViewBuilder func highScoreView() -> some View {
        HStack { Image(systemName: "trophy.fill").foregroundStyle(.yellow); Text("Рекорд: \(engine.highScore)").font(.headline).foregroundStyle(.yellow) }.opacity(highScoreOpacity).offset(y: buttonsOffset)
    }
    @ViewBuilder func skinsScrollView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(ShopSkin.all.filter { SaveManager.shared.purchasedSkins.contains($0.name) }) { skin in
                    Button { if let shipSkin = ShipSkin(rawValue: skin.name) { engine.currentSkin = shipSkin } } label: {
                        VStack { Circle().fill(skin.color).frame(width: 40, height: 40).overlay(Circle().stroke(engine.currentSkin.rawValue == skin.name ? Color.white : Color.clear, lineWidth: 3)).shadow(color: skin.color, radius: 8); Text(skin.name).font(.caption).foregroundStyle(.white.opacity(0.8)) }
                    }
                }
            }.padding(.horizontal, 10)
        }.opacity(skinsOpacity).offset(y: buttonsOffset).padding(.bottom, 5)
    }
    @ViewBuilder func weaponScrollView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(WeaponType.allCases, id: \.self) { weapon in
                    Button { engine.currentWeapon = weapon } label: {
                        VStack(spacing: 4) { Image(systemName: weaponIcon(for: weapon)).font(.title2).foregroundStyle(engine.currentWeapon == weapon ? .yellow : .white.opacity(0.6)); Text(weapon.rawValue).font(.caption2).foregroundStyle(.white) }
                            .padding(.horizontal, 12).padding(.vertical, 8).background(engine.currentWeapon == weapon ? Color.yellow.opacity(0.2) : Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(engine.currentWeapon == weapon ? Color.yellow : Color.clear, lineWidth: 1))
                    }
                }
            }.padding(.horizontal, 10)
        }.opacity(weaponOpacity).offset(y: buttonsOffset)
    }
    @ViewBuilder func actionButtons() -> some View {
        HStack(spacing: 10) {
            MenuButton(icon: "bag.fill", title: "Магазин", color: .purple) { showShop = true }
            MenuButton(icon: "gift.fill", title: "Награда", color: .pink) { showDailyReward = true }
            MenuButton(icon: "checklist", title: "Задания", color: .orange) { showDailyQuests = true }
        }.opacity(actionButtonsOpacity).offset(y: buttonsOffset)
    }
    @ViewBuilder func achievementsButton() -> some View {
        Button { showAchievements = true } label: { HStack { Image(systemName: "rosette"); Text("Достижения (\(engine.unlockedAchievements.count)/\(allAchievements.count))") }.font(.headline).foregroundStyle(.white).padding(.horizontal, 30).padding(.vertical, 12).background(.white.opacity(0.1), in: Capsule()).overlay(Capsule().stroke(.white.opacity(0.3), lineWidth: 1)) }.opacity(actionButtonsOpacity).offset(y: buttonsOffset)
    }
    @ViewBuilder func hintView() -> some View {
        Text("Джойстик — движение\nСтрельба автоматическая").font(.caption).foregroundStyle(.white.opacity(0.6)).multilineTextAlignment(.center).opacity(hintOpacity).offset(y: buttonsOffset)
    }
    @ViewBuilder func playButton() -> some View {
        Button { engine.start(size: size) } label: { Text(engine.isGameOver ? "ЕЩЁ РАЗ" : "В БОЙ").font(.title2.bold()).foregroundStyle(.black).padding(.horizontal, 50).padding(.vertical, 16).background(.white, in: Capsule()).shadow(color: engine.currentSkin.color.opacity(0.7), radius: 15).scaleEffect(playButtonScale) }.padding(.top, 5).opacity(buttonsOpacity).offset(y: buttonsOffset)
    }
    
    private func animateMenuAppearance() {
        titleOpacity = 0; titleGlow = 0; titleOffset = -50; crystalBadgeOpacity = 0; highScoreOpacity = 0; skinsOpacity = 0; weaponOpacity = 0; actionButtonsOpacity = 0; hintOpacity = 0; buttonsOpacity = 0; buttonsOffset = 30; playButtonScale = 0.8
        withAnimation(.easeOut(duration: 0.6)) { titleOpacity = 1; titleOffset = 0 }
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) { titleGlow = 20 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { crystalBadgeOpacity = 1; buttonsOffset = 0 } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { highScoreOpacity = 1 } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { skinsOpacity = 1 } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { weaponOpacity = 1 } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { actionButtonsOpacity = 1 } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { withAnimation(.easeOut(duration: 0.5)) { hintOpacity = 1 } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) { buttonsOpacity = 1; playButtonScale = 1.0 } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) { playButtonPulse = true; playButtonScale = 1.05 } }
    }
    private func weaponIcon(for type: WeaponType) -> String {
        switch type { case .standard: return "bolt.fill"; case .shotgun: return "sparkles"; case .laser: return "bolt.horizontal.fill"; case .homing: return "location.fill" }
    }
}

struct MenuButton: View {
    let icon: String; let title: String; let color: Color; let action: () -> Void
    var body: some View {
        Button(action: action) { VStack(spacing: 4) { Image(systemName: icon).font(.title2).foregroundStyle(color); Text(title).font(.caption).foregroundStyle(.white.opacity(0.8)) }.padding(.horizontal, 12).padding(.vertical, 8).background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 12)).overlay(RoundedRectangle(cornerRadius: 12).stroke(color.opacity(0.5), lineWidth: 1)) }
    }
}

// MARK: - Экран паузы
struct PauseMenuView: View {
    @Bindable var engine: GameEngine; let size: CGSize
    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea().onTapGesture { engine.togglePause() }
            VStack(spacing: 25) {
                Text("ПАУЗА").font(.system(size: 48, weight: .black, design: .rounded)).foregroundStyle(.white).shadow(color: .cyan, radius: 15)
                VStack(spacing: 15) { Text("Счёт: \(engine.score)").font(.title2).foregroundStyle(.white.opacity(0.8)); Text("Волна: \(engine.wave)").font(.headline).foregroundStyle(.cyan) }
                Button { engine.togglePause() } label: { HStack { Image(systemName: "play.fill"); Text("Продолжить") }.font(.title3.bold()).foregroundStyle(.black).padding(.horizontal, 40).padding(.vertical, 14).background(.white, in: Capsule()).shadow(color: .cyan.opacity(0.5), radius: 10) }
                Button { engine.exitToMenu() } label: { HStack { Image(systemName: "house.fill"); Text("Выйти в меню") }.font(.headline).foregroundStyle(.white).padding(.horizontal, 40).padding(.vertical, 12).background(.white.opacity(0.1), in: Capsule()).overlay(Capsule().stroke(.white.opacity(0.3), lineWidth: 1)) }
            }.padding(40).background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 30)).overlay(RoundedRectangle(cornerRadius: 30).stroke(.white.opacity(0.2), lineWidth: 1)).padding().transition(.scale.combined(with: .opacity))
        }
    }
}

struct AchievementPopupView: View {
    let achievement: Achievement
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: achievement.icon).font(.system(size: 32)).foregroundStyle(.yellow).shadow(color: .yellow, radius: 8)
            VStack(alignment: .leading, spacing: 2) { Text("ДОСТИЖЕНИЕ").font(.caption2.bold()).foregroundStyle(.yellow); Text(achievement.title).font(.headline.bold()).foregroundStyle(.white); Text(achievement.description).font(.caption).foregroundStyle(.white.opacity(0.7)) }
        }.padding(.horizontal, 20).padding(.vertical, 12).background(.ultraThinMaterial, in: Capsule()).overlay(Capsule().stroke(.yellow.opacity(0.5), lineWidth: 1)).shadow(color: .yellow.opacity(0.4), radius: 15)
    }
}

// MARK: - Магазин
struct ShopView: View {
    @Environment(\.dismiss) private var dismiss; @State private var crystals = SaveManager.shared.crystals; @State private var showAlert = false
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 20) {
                    HStack(spacing: 8) { Image(systemName: "diamond.fill").foregroundStyle(.cyan); Text("\(crystals)").font(.title.bold()).foregroundStyle(.white) }.padding(.horizontal, 20).padding(.vertical, 10).background(.ultraThinMaterial, in: Capsule())
                    Button { showAlert = true } label: { HStack { Image(systemName: "cart.fill"); Text("Купить кристаллы") }.font(.headline).foregroundStyle(.black).padding(.horizontal, 30).padding(.vertical, 12).background(.yellow, in: Capsule()) }
                    ScrollView { VStack(spacing: 12) { ForEach(ShopSkin.all) { skin in ShopSkinRow(skin: skin, crystals: $crystals) } }.padding() }
                }.padding(.top)
            }.navigationTitle("Магазин").navigationBarTitleDisplayMode(.inline).toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Закрыть") { dismiss() }.foregroundStyle(.cyan) } }
            .alert("Скоро!", isPresented: $showAlert) { Button("OK", role: .cancel) {} } message: { Text("Покупка кристаллов будет доступна в следующей версии") }
        }.preferredColorScheme(.dark)
    }
}

struct ShopSkinRow: View {
    let skin: ShopSkin; @Binding var crystals: Int; @State private var purchased = SaveManager.shared.purchasedSkins; @State private var notEnough = false
    var body: some View {
        HStack(spacing: 15) {
            Circle().fill(skin.color).frame(width: 50, height: 50).shadow(color: skin.color, radius: 10)
            VStack(alignment: .leading, spacing: 4) {
                Text(skin.name).font(.headline).foregroundStyle(.white)
                if skin.price > 0 { HStack(spacing: 4) { Image(systemName: "diamond.fill").foregroundStyle(.cyan).font(.caption); Text("\(skin.price)").font(.caption).foregroundStyle(.cyan) } } else { Text("Бесплатно").font(.caption).foregroundStyle(.green) }
            }
            Spacer()
            if purchased.contains(skin.name) { Image(systemName: "checkmark.circle.fill").foregroundStyle(.green).font(.title2) }
            else { Button { if SaveManager.shared.buySkin(skin) { purchased.insert(skin.name); crystals = SaveManager.shared.crystals } else { notEnough = true } } label: { Text("Купить").font(.headline).foregroundStyle(.black).padding(.horizontal, 20).padding(.vertical, 8).background(.yellow, in: Capsule()) } }
        }.padding().background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15)).overlay(RoundedRectangle(cornerRadius: 15).stroke(.white.opacity(0.2), lineWidth: 1))
        .alert("Не хватает кристаллов!", isPresented: $notEnough) { Button("OK", role: .cancel) {} }
    }
}

// MARK: - Ежедневная награда
struct DailyRewardView: View {
    @Environment(\.dismiss) private var dismiss; @State private var canClaim = false; @State private var claimed = false; @State private var reward = 0
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 30) {
                    Image(systemName: "gift.fill").font(.system(size: 80)).foregroundStyle(.pink).shadow(color: .pink, radius: 20)
                    Text("Ежедневная награда").font(.title.bold()).foregroundStyle(.white)
                    Text("Заходи каждый день и получай кристаллы!").font(.body).foregroundStyle(.white.opacity(0.7)).multilineTextAlignment(.center).padding(.horizontal)
                    if claimed { VStack(spacing: 10) { Text("Получено!").font(.title2.bold()).foregroundStyle(.green); HStack { Image(systemName: "diamond.fill").foregroundStyle(.cyan); Text("+\(reward)").font(.title.bold()).foregroundStyle(.cyan) } } }
                    else if canClaim { Button { claimReward() } label: { HStack { Image(systemName: "gift.fill"); Text("Забрать награду") }.font(.title3.bold()).foregroundStyle(.black).padding(.horizontal, 40).padding(.vertical, 14).background(.yellow, in: Capsule()).shadow(color: .yellow.opacity(0.5), radius: 10) } }
                    else { Text("Приходи завтра за новой наградой!").font(.headline).foregroundStyle(.white.opacity(0.7)) }
                }.padding()
            }.navigationTitle("Награда").navigationBarTitleDisplayMode(.inline).toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Закрыть") { dismiss() }.foregroundStyle(.cyan) } }.onAppear { checkReward() }
        }.preferredColorScheme(.dark)
    }
    private func checkReward() { let lastReward = SaveManager.shared.lastDailyReward; if !Calendar.current.isDateInToday(lastReward) { canClaim = true; reward = Int.random(in: 50...150) } }
    private func claimReward() { SaveManager.shared.crystals += reward; SaveManager.shared.lastDailyReward = Date(); claimed = true }
}

// MARK: - Ежедневные задания
struct DailyQuestsView: View {
    @Environment(\.dismiss) private var dismiss; @State private var quests = SaveManager.shared.dailyQuests; @State private var crystals = SaveManager.shared.crystals
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 20) {
                    HStack(spacing: 8) { Image(systemName: "diamond.fill").foregroundStyle(.cyan); Text("\(crystals)").font(.title.bold()).foregroundStyle(.white) }.padding(.horizontal, 20).padding(.vertical, 10).background(.ultraThinMaterial, in: Capsule())
                    Text("Задания обновляются каждый день").font(.caption).foregroundStyle(.white.opacity(0.6))
                    ScrollView { VStack(spacing: 12) { ForEach($quests) { $quest in QuestRow(quest: $quest) } }.padding() }
                }.padding(.top)
            }.navigationTitle("Задания").navigationBarTitleDisplayMode(.inline).toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Закрыть") { dismiss() }.foregroundStyle(.cyan) } }
        }.preferredColorScheme(.dark)
    }
}

struct QuestRow: View {
    @Binding var quest: DailyQuest
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: quest.completed ? "checkmark.circle.fill" : "circle.dashed").font(.title2).foregroundStyle(quest.completed ? .green : .gray)
            VStack(alignment: .leading, spacing: 4) {
                Text(quest.title).font(.headline).foregroundStyle(.white)
                ZStack(alignment: .leading) { Capsule().fill(Color.white.opacity(0.15)).frame(height: 8); Capsule().fill(quest.completed ? Color.green : Color.cyan).frame(width: 150 * CGFloat(quest.progress) / CGFloat(quest.target), height: 8) }.frame(width: 150)
                Text("\(quest.progress)/\(quest.target)").font(.caption).foregroundStyle(.white.opacity(0.6))
            }
            Spacer()
            HStack(spacing: 4) { Image(systemName: "diamond.fill").foregroundStyle(.cyan).font(.caption); Text("+\(quest.reward)").font(.headline).foregroundStyle(.cyan) }
        }.padding().background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15)).overlay(RoundedRectangle(cornerRadius: 15).stroke(.white.opacity(0.2), lineWidth: 1)).opacity(quest.completed ? 0.6 : 1)
    }
}

// MARK: - Экран достижений
struct AchievementsView: View {
    let engine: GameEngine; @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List(allAchievements) { ach in
                let unlocked = engine.unlockedAchievements.contains(ach.id)
                HStack(spacing: 15) {
                    Image(systemName: ach.icon).font(.system(size: 28)).foregroundStyle(unlocked ? .yellow : .gray).frame(width: 40)
                    VStack(alignment: .leading, spacing: 4) { Text(ach.title).font(.headline).foregroundStyle(unlocked ? .white : .gray); Text(ach.description).font(.caption).foregroundStyle(.gray) }
                    Spacer()
                    if unlocked { Image(systemName: "checkmark.circle.fill").foregroundStyle(.green) } else { Image(systemName: "lock.fill").foregroundStyle(.gray) }
                }.padding(.vertical, 4)
            }.scrollContentBackground(.hidden).background(Color.black).navigationTitle("Достижения").navigationBarTitleDisplayMode(.inline).toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Закрыть") { dismiss() }.foregroundStyle(.cyan) } }
        }.preferredColorScheme(.dark)
    }
}

#Preview { ContentView() }

