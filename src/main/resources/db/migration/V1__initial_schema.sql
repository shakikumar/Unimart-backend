-- Initial UniMart Schema

-- 1. User
CREATE TABLE `User` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `universityEmail` varchar(255) NOT NULL,
  `passwordHash` varchar(255) NOT NULL,
  `fullName` varchar(100) NOT NULL,
  `role` varchar(50) NOT NULL,
  `emailVerified` tinyint(1) NOT NULL DEFAULT '0',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `universityEmail` (`universityEmail`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 2. Category
CREATE TABLE `Category` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 3. Listing
CREATE TABLE `Listing` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `sellerId` bigint NOT NULL,
  `categoryId` bigint NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `price` decimal(12,2) NOT NULL,
  `status` varchar(30) NOT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `version` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk_listing_seller` (`sellerId`),
  KEY `fk_listing_category` (`categoryId`),
  CONSTRAINT `fk_listing_category` FOREIGN KEY (`categoryId`) REFERENCES `Category` (`id`),
  CONSTRAINT `fk_listing_seller` FOREIGN KEY (`sellerId`) REFERENCES `User` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 4. ListingImage
CREATE TABLE `ListingImage` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `listingId` bigint NOT NULL,
  `imageUrl` varchar(500) NOT NULL,
  `sortOrder` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_listingimage_listing` (`listingId`),
  CONSTRAINT `fk_listingimage_listing` FOREIGN KEY (`listingId`) REFERENCES `Listing` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 5. Conversation
CREATE TABLE `Conversation` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `listingId` bigint NOT NULL,
  `buyerId` bigint NOT NULL,
  `sellerId` bigint NOT NULL,
  `createdAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_conversation` (`listingId`,`buyerId`,`sellerId`),
  KEY `fk_conversation_buyer` (`buyerId`),
  KEY `fk_conversation_seller` (`sellerId`),
  CONSTRAINT `fk_conversation_buyer` FOREIGN KEY (`buyerId`) REFERENCES `User` (`id`),
  CONSTRAINT `fk_conversation_listing` FOREIGN KEY (`listingId`) REFERENCES `Listing` (`id`),
  CONSTRAINT `fk_conversation_seller` FOREIGN KEY (`sellerId`) REFERENCES `User` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 6. Message
CREATE TABLE `Message` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `conversationId` bigint NOT NULL,
  `senderId` bigint NOT NULL,
  `messageText` text NOT NULL,
  `createdAt` datetime NOT NULL,
  `readAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_message_conversation` (`conversationId`),
  KEY `fk_message_sender` (`senderId`),
  CONSTRAINT `fk_message_conversation` FOREIGN KEY (`conversationId`) REFERENCES `Conversation` (`id`),
  CONSTRAINT `fk_message_sender` FOREIGN KEY (`senderId`) REFERENCES `User` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 7. Notification
CREATE TABLE `Notification` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `userId` bigint NOT NULL,
  `type` varchar(50) NOT NULL,
  `title` varchar(255) NOT NULL,
  `body` text NOT NULL,
  `isRead` tinyint(1) NOT NULL DEFAULT '0',
  `createdAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_notification_user` (`userId`),
  CONSTRAINT `fk_notification_user` FOREIGN KEY (`userId`) REFERENCES `User` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 8. Orders
CREATE TABLE `Orders` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `listingId` bigint NOT NULL,
  `buyerId` bigint NOT NULL,
  `totalAmount` decimal(12,2) NOT NULL,
  `status` varchar(30) NOT NULL,
  `paymentMethod` varchar(50) NOT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_order_listing` (`listingId`),
  KEY `fk_order_buyer` (`buyerId`),
  CONSTRAINT `fk_order_buyer` FOREIGN KEY (`buyerId`) REFERENCES `User` (`id`),
  CONSTRAINT `fk_order_listing` FOREIGN KEY (`listingId`) REFERENCES `Listing` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 9. Payment
CREATE TABLE `Payment` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `orderId` bigint NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `status` varchar(30) NOT NULL,
  `providerReference` varchar(255) NOT NULL,
  `idempotencyKey` varchar(255) NOT NULL,
  `paidAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `orderId` (`orderId`),
  UNIQUE KEY `providerReference` (`providerReference`),
  UNIQUE KEY `idempotencyKey` (`idempotencyKey`),
  CONSTRAINT `fk_payment_order` FOREIGN KEY (`orderId`) REFERENCES `Orders` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 10. Review
CREATE TABLE `Review` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `orderId` bigint NOT NULL,
  `reviewerId` bigint NOT NULL,
  `revieweeId` bigint NOT NULL,
  `rating` int NOT NULL,
  `comment` text,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `orderId` (`orderId`),
  KEY `fk_review_reviewer` (`reviewerId`),
  KEY `fk_review_reviewee` (`revieweeId`),
  CONSTRAINT `fk_review_order` FOREIGN KEY (`orderId`) REFERENCES `Orders` (`id`),
  CONSTRAINT `fk_review_reviewee` FOREIGN KEY (`revieweeId`) REFERENCES `User` (`id`),
  CONSTRAINT `fk_review_reviewer` FOREIGN KEY (`reviewerId`) REFERENCES `User` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
