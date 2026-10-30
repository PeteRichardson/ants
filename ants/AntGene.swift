import Foundation

/// Inherited values that scale an ant's characteristics at birth.
///
/// Each gene is in the range 0.0–1.0. For example, if ants can be born with sizes from 1 to
/// 10, an ant with a `meanBirthSize` of 0.7 tends to be born with a size of about 7.
///
/// Genes don't change during an ant's life. They are set at birth and used when the ant has
/// children. The ant's current state (for example `Ant.health`) is stored on `Ant` and can
/// change when the ant is attacked, eats, or recovers.
struct AntGenes: CustomStringConvertible {
    private(set) var meanBirthSize = 0.0        // affects how big an ant is at birth
    private(set) var meanBirthHealth = 0.0      // affects how much health an ant has at birth
    private(set) var meanBiteStrength = 0.0     // affects how much damage an ant can inflict
    private(set) var meanArmorClass = 0.0       // affects how much damage an ant takes for a given hit
    private(set) var meanRecoveryRate = 0.0     // affects how quickly an ant recovers from damage
    private(set) var meanSpeed = 0.0            // affects how fast an ant can move
    private(set) var meanVisionStrength = 0.0   // affects how far an ant can see
    private(set) var meanCarryCapacity = 0.0    // affects how much an ant can carry

    /// Every gene with its short name, so that the initializers and `description` handle all
    /// genes the same way. Add new genes here.
    private static let genes: [(name: String, keyPath: WritableKeyPath<AntGenes, Double>)] = [
        ("size", \.meanBirthSize),
        ("health", \.meanBirthHealth),
        ("bite", \.meanBiteStrength),
        ("armor", \.meanArmorClass),
        ("recovery", \.meanRecoveryRate),
        ("speed", \.meanSpeed),
        ("vision", \.meanVisionStrength),
        ("capacity", \.meanCarryCapacity),
    ]

    static let randomGenes = NormalDistribution(mean: 0.5, deviation: 0.1)
    static let mutation = NormalDistribution(mean: 0.0, deviation: 0.1)

    /// One parent's gene, picked at random, plus a small normally distributed mutation,
    /// clamped to 0.0–1.0.
    static func combine(_ motherGene: Double, _ fatherGene: Double) -> Double {
        let base = Bool.random() ? motherGene : fatherGene
        return min(max(base + mutation.next(), 0), 1)
    }

    /// Creates a random set of genes from a normal distribution around 0.5.
    init() {
        for gene in Self.genes {
            self[keyPath: gene.keyPath] = Self.randomGenes.next()
        }
    }

    /// Creates a new set of genes from two parent ants.
    init(parent1: Ant, parent2: Ant) {
        for gene in Self.genes {
            self[keyPath: gene.keyPath] = Self.combine(parent1.genes[keyPath: gene.keyPath],
                                                       parent2.genes[keyPath: gene.keyPath])
        }
    }

    var description: String {
        Self.genes
            .map { "\($0.name): \(self[keyPath: $0.keyPath].formatted(.number.precision(.fractionLength(2))))" }
            .joined(separator: ", ")
    }
}
