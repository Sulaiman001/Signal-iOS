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
                let recipientStatus = self.recipientStatus(forOutgoingMessage: outgoingMessage, recipientId: recipientId)

                rows.append(valueRow(name: NSLocalizedString("MESSAGE_METADATA_VIEW_RECIPIENT",
                                                             comment: "Label for the 'recipient' field of the 'message metadata' view."),
                                     value:recipientName,
                                     subtitle:recipientStatus))

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

        // TODO: We could include the "disappearing messages" state here.

        //            @property (nullable, nonatomic) NSString *body;
        //
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
        //            //
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .long

        let recipientReadMap = message.recipientReadMap
        if let readTimestamp = recipientReadMap[recipientId] {
            assert(message.messageState == .sentToService)
            let readDate = NSDate.ows_date(withMillisecondsSince1970:readTimestamp.uint64Value)
            return String(format:NSLocalizedString("MESSAGE_STATUS_READ_WITH_TIMESTAMP_FORMAT",
                                                   comment: "message status for messages read by the recipient. Embeds: {{the date and time the message was read}}."),
                          dateFormatter.string(from:readDate))
        }

        // TODO: We don't currently track delivery state on a per-recipient basis.
        //       We should.
        if message.wasDelivered {
            return NSLocalizedString("MESSAGE_STATUS_DELIVERED",
                                     comment:"message status for message delivered to their recipient.")
        }

        if message.messageState == .unsent {
            return NSLocalizedString("MESSAGE_STATUS_FAILED", comment:"message footer for failed messages")
        } else if (message.messageState == .sentToService ||
            message.wasSent(toRecipient:recipientId)) {
            return
                NSLocalizedString("MESSAGE_STATUS_SENT",
                                  comment:"message footer for sent messages")
        } else if message.hasAttachments() {
            return NSLocalizedString("MESSAGE_STATUS_UPLOADING",
                                     comment:"message footer while attachment is uploading")
        } else {
            assert(message.messageState == .attemptingOut)

            return NSLocalizedString("MESSAGE_STATUS_SENDING",
                                     comment:"message status while message is sending.")
        }
    }

    private func nameLabel(text: String) -> UILabel {
        let label = UILabel()
        label.textColor = UIColor.black
        label.textColor = UIColor.ows_darkGray()
        label.font = UIFont.ows_mediumFont(withSize:14)
        label.text = text
        label.setContentHuggingHorizontalHigh()
        return label
    }

    private func valueLabel(text: String) -> UILabel {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.ows_regularFont(withSize:14)
        label.text = text
        label.setContentHuggingHorizontalLow()
        return label
    }

    private func valueRow(name: String, value: String, subtitle: String = "") -> UIView {
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

        if subtitle.characters.count > 0 {
            let subtitleLabel = self.valueLabel(text:subtitle)
            subtitleLabel.textColor = UIColor.ows_darkGray()
            row.addSubview(subtitleLabel)
            subtitleLabel.autoPinTrailingToSuperView()
            subtitleLabel.autoPinLeading(toTrailingOf:nameLabel, margin: 10)
            subtitleLabel.autoPinEdge(.top, to:.bottom, of:valueLabel, withOffset:1)
            subtitleLabel.autoPinEdge(toSuperviewEdge:.bottom)
        } else if value.characters.count > 0 {
            valueLabel.autoPinEdge(toSuperviewEdge:.bottom)
        } else {
            nameLabel.autoPinEdge(toSuperviewEdge:.bottom)
        }

        return row
    }

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
