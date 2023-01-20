import CoreGraphics

struct AntGenes {
    // genes are used to scale the default ranges of ant characteristics at birth
    //
    // they are CGFloats in the range 0.0-1.0
    // e.g. if, overall ants can range from size 1 to 10 at birth, then
    // ants with a meanBirthSize gene value of 0.7 will tend to be born
    // with sizes around 7.
    //
    // Note that genes don't change in an individual. They are set at birth
    // and used when the individual has children.   There are other fields
    // in the Ant object used for the characteristics of the individual
    // e.g. myAnt.health is the current value of this ants health.  It can change
    // if the ant is attacked or eats food or recovers.
    //
    // There's an initializer that takes a mother ant and father ant and
    // generates a gene based on the parents' gene values.
    //

    let meanBirthSize : CGFloat         // affects how big an ant is at birth
    let meanBirthHealth : CGFloat       // affects how much health an ant has at birth
    let meanRecoveryRate : CGFloat      // affects how quickly an ant recovers from damage
    let meanBiteStrength : CGFloat      // affects how much damage an ant can inflict
    let meanSpeed : CGFloat             // affects how fast an ant can move
    let meanVisionStrength : CGFloat    // affects how far an ant can see
    let meanCarryCapacity : CGFloat          // affects how much an ant can carry
    
    private static func combine(_ mg : CGFloat, _ fg : CGFloat) -> CGFloat {
        // average of mothers and fathers gene + small random factor?
        // TODO: random factor here should all be from a normal distribution
         return (mg + fg) / 2.0 + CGFloat.random(in: -0.1...0.1)
    }
    
    // Create a random set of genes
    // TODO:  these random factors should all be from a normal distribution
    init() {
        self.meanBirthSize = CGFloat.random(in: 0.0...1.0)
        self.meanBirthHealth = CGFloat.random(in: 0.0...1.0)
        self.meanBiteStrength = CGFloat.random(in: 0.0...1.0)
        self.meanRecoveryRate = CGFloat.random(in: 0.0...1.0)
        self.meanSpeed = CGFloat.random(in: 0.0...1.0)
        self.meanVisionStrength = CGFloat.random(in: 0.0...1.0)
        self.meanCarryCapacity = CGFloat.random(in: 0.0...1.0)
    }
    
    // Create a new set of genes based on two parent ants
    init(parent1: Ant, parent2: Ant) {
        let genes1 = parent1.genes
        let genes2 = parent2.genes
        self.meanBirthSize = AntGenes.combine(genes1.meanBirthSize, genes2.meanBirthSize)
        self.meanBirthHealth = AntGenes.combine(genes1.meanBirthHealth, genes2.meanBirthHealth)
        self.meanBiteStrength = AntGenes.combine(genes1.meanBiteStrength, genes2.meanBiteStrength)
        self.meanRecoveryRate = AntGenes.combine(genes1.meanRecoveryRate, genes2.meanRecoveryRate)
        self.meanSpeed = AntGenes.combine(genes1.meanSpeed, genes2.meanSpeed)
        self.meanVisionStrength = AntGenes.combine(genes1.meanVisionStrength, genes2.meanVisionStrength)
        self.meanCarryCapacity = AntGenes.combine(genes1.meanCarryCapacity, genes2.meanCarryCapacity)
    }
}
