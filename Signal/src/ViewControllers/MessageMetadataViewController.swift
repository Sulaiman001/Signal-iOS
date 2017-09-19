//
//  Copyright (c) 2017 Open Whisper Systems. All rights reserved.
//

import Foundation
//import MediaPlayer

class MessageMetadataViewController: OWSViewController
//, OWSAudioAttachmentPlayerDelegate
{

    let TAG = "[MessageMetadataViewController]"

    // MARK: Properties

    let message: TSMessage

    var mediaMessageView: MediaMessageView?

    var scrollView: UIScrollView?
    var contentView: UIView?

//    let attachment: SignalAttachment
//
//    var successCompletion : (() -> Void)?

    // MARK: Initializers

    @available(*, unavailable, message:"use message: constructor instead.")
    required init?(coder aDecoder: NSCoder) {
        self.message = TSMessage()
        super.init(coder: aDecoder)
        owsFail("\(self.TAG) invalid constructor")
    }

    required init(message: TSMessage) {
        self.message = message
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = NSLocalizedString("MESSAGE_METADATA_VIEW_TITLE",
                                                      comment: "Title for the 'message metadata' view.")

        createViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        mediaMessageView?.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        mediaMessageView?.viewWillDisappear(animated)
    }

    // MARK: - Create Views

    private func createViews() {
        view.backgroundColor = UIColor.white

        let scrollView = UIScrollView()
        self.scrollView = scrollView
        view.addSubview(scrollView)
        scrollView.autoPinWidthToSuperview(withMargin:0)
        scrollView.autoPin(toTopLayoutGuideOf: self, withInset:0)
        scrollView.autoPin(toBottomLayoutGuideOf: self, withInset:0)

        // See notes on how to use UIScrollView with iOS Auto Layout:
        //
        // https://developer.apple.com/library/content/releasenotes/General/RN-iOSSDK-6_0/
        let contentView = UIView.container()
        self.contentView = contentView
        scrollView.addSubview(contentView)
        contentView.autoPinLeadingToSuperView()
        contentView.autoPinTrailingToSuperView()
        contentView.autoPinEdge(toSuperviewEdge:.top)
        contentView.autoPinEdge(toSuperviewEdge:.bottom)

        var rows = [UIView]()

        let contactsManager = Environment.getCurrent().contactsManager!

        // Sender?
        if let incomingMessage = message as? TSIncomingMessage {
            let senderId = incomingMessage.authorId
            let senderName = contactsManager.contactOrProfileName(forPhoneIdentifier:senderId)
            rows.append(valueRow(name: NSLocalizedString("MESSAGE_METADATA_VIEW_SENDER",
                                                         comment: "Label for the 'sender' field of the 'message metadata' view."),
                                 value:senderName))
        }

        // Recipient(s)?
        let thread = message.thread

        if let outgoingMessage = message as? TSOutgoingMessage {
            for recipientId in thread.recipientIdentifiers {
                let recipientName = contactsManager.contactOrProfileName(forPhoneIdentifier:recipientId)

                rows.append(valueRow(name: NSLocalizedString("MESSAGE_METADATA_VIEW_RECIPIENT",
                                                             comment: "Label for the 'recipient' field of the 'message metadata' view."),
                                     value:recipientName))
//                if recipientId != threadName {
//                    if threadName.characters.count > 0 {
//                        rows.append(valueRow(name: NSLocalizedString("MESSAGE_METADATA_VIEW_CONTACT_THREAD_NAME",
//                                                                     comment: "Label for the 'contact thread name' field of the 'message metadata' view."),
//                                             value:threadName))
//                    }
//                }
            }

//            if let contactThread = thread as? TSContactThread {
//                let recipientId = contactThread.contactIdentifier()
//                let threadName = contactsManager.stringForMessageFooter(forPhoneIdentifier:recipientId)
//
//                rows.append(valueRow(name: NSLocalizedString("MESSAGE_METADATA_VIEW_CONTACT_THREAD_ID",
//                                                             comment: "Label for the 'contact thread id' field of the 'message metadata' view."),
//                                     value:recipientId))
//                if recipientId != threadName {
//                    if threadName.characters.count > 0 {
//                        rows.append(valueRow(name: NSLocalizedString("MESSAGE_METADATA_VIEW_CONTACT_THREAD_NAME",
//                                                                     comment: "Label for the 'contact thread name' field of the 'message metadata' view."),
//                                             value:threadName))
//                    }
//                }
//            }
        }

        if let groupThread = thread as? TSGroupThread {
            var groupName = groupThread.name()
            if groupName.characters.count < 1 {
                groupName = NSLocalizedString("NEW_GROUP_DEFAULT_TITLE", comment: "")
            }

            rows.append(valueRow(name: NSLocalizedString("MESSAGE_METADATA_VIEW_GROUP_NAME",
                                                         comment: "Label for the 'group name' field of the 'message metadata' view."),
                                 value:groupName))
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .long

        let sentDate = NSDate.ows_date(withMillisecondsSince1970:message.timestamp)
        rows.append(valueRow(name: NSLocalizedString("MESSAGE_METADATA_VIEW_SENT_DATE_TIME",
                                                     comment: "Label for the 'sent date & time' field of the 'message metadata' view."),
                             value:dateFormatter.string(from:sentDate)))

        if let incomingMessage = message as? TSIncomingMessage {
            let receivedDate = message.dateForSorting()
            rows.append(valueRow(name: NSLocalizedString("MESSAGE_METADATA_VIEW_RECEIVED_DATE_TIME",
                                                         comment: "Label for the 'received date & time' field of the 'message metadata' view."),
                                 value:dateFormatter.string(from:receivedDate)))
        }

//        @end
//            @property (nonatomic, readonly) NSMutableArray<NSString *> *attachmentIds;
//            @property (nullable, nonatomic) NSString *body;
//            @property (nonatomic) uint32_t expiresInSeconds;
//            @property (nonatomic) uint64_t expireStartedAt;
//            @property (nonatomic, readonly) uint64_t expiresAt;
//            @property (nonatomic, readonly) BOOL isExpiringMessage;
//            @property (nonatomic, readonly) BOOL shouldStartExpireTimer;

//            @property (nonatomic, readonly) NSString *uniqueThreadId;
//            @property (nonatomic, readonly) TSThread *thread;
//            @property (nonatomic, readonly) uint64_t timestamp;
//            
//            - (NSString *)description;
//            
//            /**
//             * When an interaction is updated, it often affects the UI for it's containing thread. Touching it's thread will notify
//             * any observers so they can redraw any related UI.
//             */
//            - (void)touchThreadWithTransaction:(YapDatabaseReadWriteTransaction *)transaction;
//            
//            #pragma mark Utility Method
//            
//            + (instancetype)interactionForTimestamp:(uint64_t)timestamp
//            withTransaction:(YapDatabaseReadWriteTransaction *)transaction;
//            
//            - (NSDate *)dateForSorting;
//            - (uint64_t)timestampForSorting;
//            - (NSComparisonResult)compareForSorting:(TSInteraction *)other;
//
//            @end
//            
//            NS_ASSUME_NONNULL_END

//            @property (atomic, readonly) TSOutgoingMessageState messageState;
//            
//            // The message has been sent to the service and received by at least one recipient client.
//            // A recipient may have more than one client, and group message may have more than one recipient.
//            @property (atomic, readonly) BOOL wasDelivered;
//            
//            @property (atomic, readonly) BOOL hasSyncedTranscript;
//            @property (atomic, readonly) NSString *customMessage;
//            @property (atomic, readonly) NSString *mostRecentFailureText;
//            // A map of attachment id-to-"source" filename.
//            @property (nonatomic, readonly) NSMutableDictionary<NSString *, NSString *> *attachmentFilenameMap;
//            
//            @property (atomic, readonly) TSGroupMetaMessage groupMetaMessage;
//            
//            // If set, this group message should only be sent to a single recipient.
//            @property (atomic, readonly) NSString *singleGroupRecipient;
//
//            // The recipient ids of the recipients who have read the message.
//            @property (atomic, readonly) NSSet<NSString *> *readRecipientIds;
//            
//            /**
//             * Signal Identifier (e.g. e164 number) or nil if in a group thread.
//             */
//            - (nullable NSString *)recipientIdentifier;
//
//            #pragma mark - Sent Recipients
//            
//            - (NSUInteger)sentRecipientsCount;
//            - (BOOL)wasSentToRecipient:(NSString *)contactId;
//            - (void)updateWithSentRecipient:(NSString *)contactId transaction:(YapDatabaseReadWriteTransaction *)transaction;
//            - (void)updateWithSentRecipient:(NSString *)contactId;
//            
//            @end
//            
//            NS_ASSUME_NONNULL_END
//
//            
            DispatchQueue.main.async {
//                Logger.error("senderRow: \(NSStringFromCGRect(senderRow.frame))")
                Logger.error("scrollView: \(NSStringFromCGRect(scrollView.frame))")
                Logger.error("scrollView: \(NSStringFromCGSize(scrollView.contentSize))")
                Logger.error("contentView: \(NSStringFromCGRect(contentView.frame))")
                }

        if message.attachmentIds.count > 0 {
            let attachmentId = message.attachmentIds[0] as! String
            let attachment = TSAttachment.fetch(uniqueId:attachmentId)
            if let attachment = attachment {
                let contentType = attachment.contentType
                rows.append(valueRow(name: NSLocalizedString("MESSAGE_METADATA_VIEW_ATTACHMENT_MIME_TYPE",
                                                             comment: "Label for the MIME type of attachments in the 'message metadata' view."),
                                     value:contentType))

                if let sourceFilename = attachment.sourceFilename {
                rows.append(valueRow(name: NSLocalizedString("MESSAGE_METADATA_VIEW_SOURCE_FILENAME",
                                                             comment: "Label for the original filename of any attachment in the 'message metadata' view."),
                                     value:sourceFilename))
                }

                if let attachmentStream = attachment as? TSAttachmentStream {
                    var dataSource: DataSource?
                    if let filePath = attachmentStream.filePath() {
                        dataSource = DataSourcePath.dataSource(withFilePath:filePath)
                    }
                    if let dataSource = dataSource {
                        let fileSize = dataSource.dataLength()
                        rows.append(valueRow(name: NSLocalizedString("MESSAGE_METADATA_VIEW_ATTACHMENT_FILE_SIZE",
                                                                     comment: "Label for file size of attachments in the 'message metadata' view."),
                                             value:ViewControllerUtils.formatFileSize(UInt(fileSize))))

                        if (attachmentStream.isAnimated() ||
                            attachmentStream.isImage() ||
                            attachmentStream.isVideo() ||
                            attachmentStream.isAudio()) {

                            if let dataUTI = MIMETypeUtil.utiType(forMIMEType:contentType) {
                                if attachment.isVoiceMessage() {
                                    rows.append(valueRow(name: NSLocalizedString("MESSAGE_METADATA_VIEW_VOICE_MESSAGE",
                                                                                 comment: "Label for voice messages of the 'message metadata' view."),
                                                         value:""))
                                } else {
                                    rows.append(valueRow(name: NSLocalizedString("MESSAGE_METADATA_VIEW_MEDIA",
                                                                                 comment: "Label for media messages of the 'message metadata' view."),
                                                         value:""))
                                }
                                let attachment = SignalAttachment(dataSource : dataSource, dataUTI: dataUTI)
                                let mediaMessageView = MediaMessageView(attachment:attachment)
                                self.mediaMessageView = mediaMessageView
                                rows.append(mediaMessageView)
                            }
                        }
                    } else {
                        rows.append(valueRow(name: NSLocalizedString("MESSAGE_METADATA_VIEW_ATTACHMENT_MISSING_FILE",
                                                                     comment: "Label for 'missing' attachments in the 'message metadata' view."),
                                             value:""))
                    }
                } else {
                    rows.append(valueRow(name: NSLocalizedString("MESSAGE_METADATA_VIEW_ATTACHMENT_NOT_YET_DOWNLOADED",
                                                                 comment: "Label for 'not yet downloaded' attachments in the 'message metadata' view."),
                                         value:""))
                }
            }
        } else if let messageBody = message.body {
            if messageBody.characters.count > 0 {

            } else {
                // Neither attachment nor body.
            }
        }

        var lastRow: UIView?
        for row in rows {
            contentView.addSubview(row)
            row.autoPinLeadingToSuperView()
            row.autoPinTrailingToSuperView()

            if let lastRow = lastRow {
                row.autoPinEdge(.top, to:.bottom, of:lastRow, withOffset:5)
            } else {
                row.autoPinEdge(toSuperviewEdge:.top, withInset:20)
            }

            lastRow = row
        }
        if let lastRow = lastRow {
            lastRow.autoPinEdge(toSuperviewEdge:.bottom, withInset:20)
        }

        if let mediaMessageView = mediaMessageView {
            mediaMessageView.autoPinToSquareAspectRatio()
        }
    }

    private func recipientStatus(forOutgoingMessage message: TSOutgoingMessage, recipientId: String) -> String {
//        switch message.messageState {
//            case .unsent:
//            return NSLocalizedString("MESSAGE_STATUS_FAILED", comment:"message footer for failed messages")
////        default:
////            owsFail
////            return ""
//        }
//        if message.messageState == .unsent {
//            return NSLocalizedString("MESSAGE_STATUS_FAILED", comment:"message footer for failed messages")
//        } else if message.messageState == .sentToService {
//            NSString *text = (message.wasDelivered
//                ? NSLocalizedString("MESSAGE_STATUS_DELIVERED", comment:"message footer for delivered messages")
//                : NSLocalizedString("MESSAGE_STATUS_SENT", comment:"message footer for sent messages"));
//            NSAttributedString *result = [[NSAttributedString alloc] initWithString:text];
//            if (message.wasDelivered && message.readRecipientIds.count > 0) {
//                NSAttributedString *checkmark = [[NSAttributedString alloc]
//                    initWithString:@"\uf00c "
//                    attributes:@{
//                    NSFontAttributeName : [UIFont ows_fontAwesomeFont:10.f],
//                    NSForegroundColorAttributeName : [UIColor ows_materialBlueColor],
//                    }];
//                NSAttributedString *spacing = [[NSAttributedString alloc] initWithString:@" "];
//                result = [[checkmark rtlSafeAppend:spacing referenceView:self.view] rtlSafeAppend:result
//                    referenceView:self.view];
//            }
//            
//            // Show when it's the last message in the thread
//            if (indexPath.item == [self.collectionView numberOfItemsInSection:indexPath.section] - 1) {
//                [self updateLastDeliveredMessage:message];
//                return result;
//            }
//            
//            // Or when the next message is *not* an outgoing sent/delivered message.
//            TSOutgoingMessage *nextMessage = [self nextOutgoingMessage:indexPath];
//            if (nextMessage && nextMessage.messageState == TSOutgoingMessageStateUnsent) {
//                [self updateLastDeliveredMessage:message];
//                return result;
//            }
//        } else if message.isMediaBeingSent() {
//            return [[NSAttributedString alloc] initWithString:NSLocalizedString("MESSAGE_STATUS_UPLOADING",
//                comment:"message footer while attachment is uploading")];
//        } else {
//            OWSAssert(message.messageState == .attemptingOut)
//            // Show an "..." ellisis icon.
//            //
//            // TODO: It'd be nice to animate this, but JSQMessageViewController doesn't give us a great way to do so.
//            //       We already have problems with unstable cell layout; we don't want to exacerbate them.
//            NSAttributedString *result =
//                [[NSAttributedString alloc] initWithString:@"/"
//                    attributes:@{
//                    NSFontAttributeName : [UIFont ows_dripIconsFont:14.f],
//                    }];
//            return result;
//        }

        return ""
    }

    private func nameLabel(text: String) -> UILabel {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.ows_mediumFont(withSize:14)
        label.text = text
        return label
    }

    private func valueLabel(text: String) -> UILabel {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.ows_regularFont(withSize:14)
        label.text = text
        return label
    }

    private func valueRow(name: String, value: String) -> UIView {
        let row = UIView.container()
        let nameLabel = self.nameLabel(text:name)
        let valueLabel = self.valueLabel(text:value)
        row.addSubview(nameLabel)
        row.addSubview(valueLabel)
        nameLabel.autoPinLeadingToSuperView()
        valueLabel.autoPinTrailingToSuperView()
        valueLabel.autoPinLeading(toTrailingOf:nameLabel, margin: 10)
        nameLabel.autoPinEdge(toSuperviewEdge:.top)
        valueLabel.autoPinEdge(toSuperviewEdge:.top)
        nameLabel.autoPinEdge(toSuperviewEdge:.bottom)

//        DispatchQueue.main.async {
//            Logger.error("nameLabel: \(NSStringFromCGRect(nameLabel.frame)) \(name)")
//            Logger.error("nameLabel: \(NSStringFromCGSize(nameLabel.sizeThatFits(CGSize.zero)))")
//            Logger.error("valueLabel: \(NSStringFromCGRect(valueLabel.frame)) \(value)")
//            Logger.error("valueLabel: \(NSStringFromCGSize(valueLabel.sizeThatFits(CGSize.zero)))")
//            Logger.error("row: \(NSStringFromCGRect(row.frame))")
//        }
        return row
    }

//    private func wrapViewsInVerticalStack(subviews: [UIView]) -> UIView {
//        assert(subviews.count > 0)
//
//        let stackView = UIView()
//
//        var lastView: UIView?
//        for subview in subviews {
//
//            stackView.addSubview(subview)
//            subview.autoHCenterInSuperview()
//
//            if lastView == nil {
//                subview.autoPinEdge(toSuperviewEdge:.top)
//            } else {
//                subview.autoPinEdge(.top, to:.bottom, of:lastView!, withOffset:10)
//            }
//
//            lastView = subview
//        }
//
//        lastView?.autoPinEdge(toSuperviewEdge:.bottom)
//
//        return stackView
//    }
////
//    private func labelFont() -> UIFont {
//        return UIFont.ows_regularFont(withSize:ScaleFromIPhone5To7Plus(18, 24))
//    }
//
//    private func formattedFileExtension() -> String? {
//        guard let fileExtension = attachment.fileExtension else {
//            return nil
//        }
//
//        return String(format:NSLocalizedString("ATTACHMENT_APPROVAL_FILE_EXTENSION_FORMAT",
//                                               comment: "Format string for file extension label in call interstitial view"),
//                      fileExtension.uppercased())
//    }
//
//    private func formattedFileName() -> String? {
//        guard let sourceFilename = attachment.sourceFilename else {
//            return nil
//        }
//        let filename = sourceFilename.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
//        guard filename.characters.count > 0 else {
//            return nil
//        }
//        return filename
//    }
//
//    private func createFileNameLabel() -> UIView? {
//        let filename = formattedFileName() ?? formattedFileExtension()
//
//        guard filename != nil else {
//            return nil
//        }
//
//        let label = UILabel()
//        label.text = filename
//        label.textColor = UIColor.ows_materialBlue()
//        label.font = labelFont()
//        label.textAlignment = .center
//        label.lineBreakMode = .byTruncatingMiddle
//        return label
//    }
//
//    private func createFileSizeLabel() -> UIView {
//        let label = UILabel()
//        let fileSize = attachment.dataLength
//        label.text = String(format:NSLocalizedString("ATTACHMENT_APPROVAL_FILE_SIZE_FORMAT",
//                                                     comment: "Format string for file size label in call interstitial view. Embeds: {{file size as 'N mb' or 'N kb'}}."),
//                            ViewControllerUtils.formatFileSize(UInt(fileSize)))
//
//        label.textColor = UIColor.ows_materialBlue()
//        label.font = labelFont()
//        label.textAlignment = .center
//
//        return label
//    }
//
//    private func createAudioStatusLabel() -> UILabel {
//        let label = UILabel()
//        label.textColor = UIColor.ows_materialBlue()
//        label.font = labelFont()
//        label.textAlignment = .center
//
//        return label
//    }
//
//    private func createButtonRow(attachmentPreviewView: UIView) {
//        let buttonTopMargin = ScaleFromIPhone5To7Plus(30, 40)
//        let buttonBottomMargin = ScaleFromIPhone5To7Plus(25, 40)
//        let buttonHSpacing = ScaleFromIPhone5To7Plus(20, 30)
//
//        let buttonRow = UIView()
//        self.view.addSubview(buttonRow)
//        buttonRow.autoPinWidthToSuperview()
//        buttonRow.autoPinEdge(toSuperviewEdge:.bottom, withInset:buttonBottomMargin)
//        buttonRow.autoPinEdge(.top, to:.bottom, of:attachmentPreviewView, withOffset:buttonTopMargin)
//
//        // We use this invisible subview to ensure that the buttons are centered
//        // horizontally.
//        let buttonSpacer = UIView()
//        buttonRow.addSubview(buttonSpacer)
//        // Vertical positioning of this view doesn't matter.
//        buttonSpacer.autoPinEdge(toSuperviewEdge:.top)
//        buttonSpacer.autoSetDimension(.width, toSize:buttonHSpacing)
//        buttonSpacer.autoHCenterInSuperview()
//
//        let cancelButton = createButton(title: CommonStrings.cancelButton,
//                                        color : UIColor.ows_destructiveRed(),
//                                        action: #selector(cancelPressed))
//        buttonRow.addSubview(cancelButton)
//        cancelButton.autoPinEdge(toSuperviewEdge:.top)
//        cancelButton.autoPinEdge(toSuperviewEdge:.bottom)
//        cancelButton.autoPinEdge(.right, to:.left, of:buttonSpacer)
//
//        let sendButton = createButton(title: NSLocalizedString("ATTACHMENT_APPROVAL_SEND_BUTTON",
//                                                               comment: "Label for 'send' button in the 'attachment approval' dialog."),
//                                      color : UIColor(rgbHex:0x2ecc71),
//                                      action: #selector(sendPressed))
//        buttonRow.addSubview(sendButton)
//        sendButton.autoPinEdge(toSuperviewEdge:.top)
//        sendButton.autoPinEdge(toSuperviewEdge:.bottom)
//        sendButton.autoPinEdge(.left, to:.right, of:buttonSpacer)
//    }
//
//    private func createButton(title: String, color: UIColor, action: Selector) -> UIView {
//        let buttonWidth = ScaleFromIPhone5To7Plus(110, 140)
//        let buttonHeight = ScaleFromIPhone5To7Plus(35, 45)
//
//        return OWSFlatButton.button(title:title,
//                                    titleColor:UIColor.white,
//                                    backgroundColor:color,
//                                    width:buttonWidth,
//                                    height:buttonHeight,
//                                    target:target,
//                                    selector:action)
//    }
//
//    // MARK: - Event Handlers
//
//    func donePressed(sender: UIButton) {
//        dismiss(animated: true, completion:nil)
//    }
//
//    func cancelPressed(sender: UIButton) {
//        dismiss(animated: true, completion:nil)
//    }
//
//    func sendPressed(sender: UIButton) {
//        let successCompletion = self.successCompletion
//        dismiss(animated: true, completion: {
//            successCompletion?()
//        })
//    }
}
