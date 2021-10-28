// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

// nft contract to extend
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Openzeppelin utilities
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./libraries/Base64.sol";

import "hardhat/console.sol";

contract MyEpicGame is ERC721 {
    // We'll hold the characters attributes in a struct
    struct CharacterAttributes {
        uint256 characterIndex;
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // An array of default characters
    CharacterAttributes[] defaultCharacters;

    // A map of nft tokenIds to character attributes
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    // A map of nft holder address to their tokens
    mapping(address => uint256) public nftHolders;

    struct BigBoss {
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
    }

    BigBoss public bigBoss;

    // Events to confirm particular action successful completion
    event ComradeNFTMinted(
        address sender,
        uint256 tokenId,
        uint256 characterIndex
    );
    event AttackComplete(uint256 bossNewHp, uint256 playerNewHp);

    constructor(
        string[] memory charactersNames,
        string[] memory charactersimageURIs,
        uint256[] memory charactersHPs,
        uint256[] memory charactersAttackDamages,
        string memory bigBossName,
        string memory bigBossImageURI,
        uint256 bigBossHp,
        uint256 bigBossAttackDamage
    ) ERC721("Comrades", "COMRADE") {
        bigBoss = BigBoss({
            name: bigBossName,
            imageURI: bigBossImageURI,
            hp: bigBossHp,
            maxHp: bigBossHp,
            attackDamage: bigBossAttackDamage
        });

        console.log(
            "Done initializing boss %s w/ HP %s, img %s",
            bigBoss.name,
            bigBoss.hp,
            bigBoss.imageURI
        );

        // Iterate the input arrays and create the default set of characters using the struct
        for (uint256 i = 0; i < charactersNames.length; i++) {
            defaultCharacters.push(
                CharacterAttributes({
                    characterIndex: i,
                    name: charactersNames[i],
                    imageURI: charactersimageURIs[i],
                    hp: charactersHPs[i],
                    maxHp: charactersHPs[i],
                    attackDamage: charactersAttackDamages[i]
                })
            );
            CharacterAttributes memory c = defaultCharacters[i];
            console.log(
                "Done initializing %s w/ HP %s, img %s",
                c.name,
                c.hp,
                c.imageURI
            );
        }
        _tokenIds.increment();
    }

    function mintCharacterNFT(uint256 _characterIndex) external {
        uint256 _newItemId = _tokenIds.current();

        // Mint a new NFT
        _safeMint(msg.sender, _newItemId);

        // map the character attributes to the new token id
        nftHolderAttributes[_newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            hp: defaultCharacters[_characterIndex].hp,
            maxHp: defaultCharacters[_characterIndex].maxHp,
            attackDamage: defaultCharacters[_characterIndex].attackDamage
        });

        console.log(
            "Minted NFT w/ tokenId %s and characterIndex %s",
            _newItemId,
            _characterIndex
        );

        // map the nft holder to the new token id
        nftHolders[msg.sender] = _newItemId;

        // emit the event
        emit ComradeNFTMinted(msg.sender, _newItemId, _characterIndex);

        // Increment the tokenIds counter for next request to avoid collison
        _tokenIds.increment();
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        CharacterAttributes memory charAttributes = nftHolderAttributes[
            _tokenId
        ];
        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxHp);
        string memory strAttackDamage = Strings.toString(
            charAttributes.attackDamage
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        charAttributes.name,
                        " --NFT #: ",
                        Strings.toString(_tokenId),
                        '", "description": "',
                        "This is an NFT that lets people play in the game MetaVerse Facist Slayer!",
                        '", "image": "ipfs://',
                        charAttributes.imageURI,
                        '", "attributes": [ { "trait_type": "Health Points", "value": ',
                        strHp,
                        ', "max_value":',
                        strMaxHp,
                        '}, { "trait_type": "Attack Damage", "value": ',
                        strAttackDamage,
                        "} ]}"
                    )
                )
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    function attackBoss() public {
        // Get the state of the players NFT
        uint256 tokenIdOfPlayer = nftHolders[msg.sender];
        CharacterAttributes storage player = nftHolderAttributes[
            tokenIdOfPlayer
        ];
        console.log(
            "\nPlayer w/ character %s about to attack. Has %s HP and %s AD",
            player.name,
            player.hp,
            player.attackDamage
        );
        console.log(
            "\nBoss %s about to attack. Has %s HP and %s AD",
            bigBoss.name,
            bigBoss.hp,
            bigBoss.attackDamage
        );

        // Make sure the player has more than 0 HP
        require(player.hp > 0, "Error: character must have HP to attack boss.");

        // Make sure the big boss has more than 0 HP
        require(
            bigBoss.hp > 0,
            "Error: BigBoss must have HP to attack the character."
        );

        // Allow player to attack boss
        if (bigBoss.hp < player.attackDamage) {
            bigBoss.hp = 0;
        } else {
            bigBoss.hp -= player.attackDamage;
        }

        console.log(
            "\nBigBoss %s attacked, Has %s HP and %s AD",
            bigBoss.name,
            bigBoss.hp,
            bigBoss.attackDamage
        );

        // Allow boss to attack player
        if (player.hp < bigBoss.attackDamage) {
            player.hp = 0;
        } else {
            player.hp -= bigBoss.attackDamage;
        }

        console.log(
            "\nPlayer %s attacked, Has %s HP and %s AD",
            player.name,
            player.hp,
            player.attackDamage
        );

        // Emit the attack complete event
        emit AttackComplete(bigBoss.hp, player.hp);
    }

    function checkIfUserHasNFT()
        public
        view
        returns (CharacterAttributes memory)
    {
        // Get the tokenId of the NFT for the current player
        uint256 nftTokenId = nftHolders[msg.sender];

        // tokenId starts at 1, so if the tokenId is 0, the player doesn't have an NFT
        if (nftTokenId > 0) {
            return nftHolderAttributes[nftTokenId];
        } else {
            // return an empty struct to denote there is no NFT for the player
            CharacterAttributes memory emptyStruct;
            return emptyStruct;
        }
    }

    function getBigBoss() public view returns (BigBoss memory) {
        return bigBoss;
    }

    function getAllDefaultCharacters()
        public
        view
        returns (CharacterAttributes[] memory)
    {
        return defaultCharacters;
    }
}
